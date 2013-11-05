class LumDefPawn extends Pawn;

// Dynamic light environment component to help speed up lighting calculations for the pawn
var(Pawn) const DynamicLightEnvironmentComponent LightEnvironment;
// How fast a pawn turns
var(Pawn) const float TurnRate;
// How high the pawn jumps
var(Pawn) const float JumpHeight;
// Socket to use for attaching weapons
var(Pawn) const Name WeaponSocketName;
// Height to set the collision cylinder when crouching
var(Pawn) const float CrouchHeightOverride<DisplayName=Crouch Height>;
// Radius to set the collision cylinder when crouching
var(Pawn) const float CrouchRadiusOverride<DisplayName=Crouch Radius>;

// Reference to the aim node aim offset node
var AnimNodeAimOffset AimNode;
// Reference to the gun recoil skel controller node
var GameSkelCtrl_Recoil GunRecoilNode;
// Internal int which stores the desired yaw of the pawn
var int DesiredYaw;
// Internal int which store the current yaw of the pawn
var int CurrentYaw;
// Internal int which stores the current pitch of the pawn
var int CurrentPitch;


simulated function PostBeginPlay()
{
        Super.PostBeginPlay();
        `Log("\n\nLumDefPawn its up!\n");
        SpawnDefaultController();
        AddDefaultInventory();

}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	if (SkelComp == Mesh)
	{
		// Find the aim offset node
		AimNode = AnimNodeAimOffset(Mesh.FindAnimNode('AimNode'));
		// Find the gun recoil skeletal control node
		GunRecoilNode = GameSkelCtrl_Recoil(Mesh.FindSkelControl('GunRecoilNode'));
	}
}

simulated function Rotator GetAdjustedAimFor(Weapon W, vector StartFireLoc)
{
	local Vector SocketLocation;
	local Rotator SocketRotation;
	local LumDefWeapon LumDefWeapon;
	local SkeletalMeshComponent WeaponSkeletalMeshComponent;

	LumDefWeapon = LumDefWeapon(Weapon);
	if (LumDefWeapon != None)
	{
		WeaponSkeletalMeshComponent = SkeletalMeshComponent(LumDefWeapon.Mesh);
		if (WeaponSkeletalMeshComponent != None && WeaponSkeletalMeshComponent.GetSocketByName(LumDefWeapon.MuzzleSocketName) != None)
		{			
			WeaponSkeletalMeshComponent.GetSocketWorldLocationAndRotation(LumDefWeapon.MuzzleSocketName, SocketLocation, SocketRotation);
			return SocketRotation;
		}
	}

	return Rotation;
}

simulated event Vector GetWeaponStartTraceLocation(optional Weapon CurrentWeapon)
{
	local Vector SocketLocation;
	local Rotator SocketRotation;
	local LumDefWeapon LumDefWeapon;
	local SkeletalMeshComponent WeaponSkeletalMeshComponent;

	LumDefWeapon = LumDefWeapon(Weapon);
	if (LumDefWeapon != None)
	{
		WeaponSkeletalMeshComponent = SkeletalMeshComponent(LumDefWeapon.Mesh);
		if (WeaponSkeletalMeshComponent != None && WeaponSkeletalMeshComponent.GetSocketByName(LumDefWeapon.MuzzleSocketName) != None)
		{
			WeaponSkeletalMeshComponent.GetSocketWorldLocationAndRotation(LumDefWeapon.MuzzleSocketName, SocketLocation, SocketRotation);
			return SocketLocation;
		}
	}

	return Super.GetWeaponStartTraceLocation(CurrentWeapon);
}

simulated function FaceRotation(Rotator NewRotation, float DeltaTime)
{
	local Rotator FacingRotation;

	// Set the desired yaw the new rotation yaw
	if (NewRotation.Yaw != 0)
	{
		DesiredYaw = NewRotation.Yaw;
	}

	// If the current yaw doesn't match the desired yaw, then interpolate towards it
	if (CurrentYaw != DesiredYaw)
	{
		CurrentYaw = Lerp(CurrentYaw, DesiredYaw, TurnRate * DeltaTime);
	}

	// If we have a valid aim offset node
	if (AimNode != None)
	{
		// Clamp the current pitch to the view pitch min and view pitch max
		CurrentPitch = Clamp(CurrentPitch + NewRotation.Pitch, ViewPitchMin, ViewPitchMax);

		if (CurrentPitch > 0.f)
		{
			// Handle when we're aiming up
			AimNode.Aim.Y = float(CurrentPitch) / ViewPitchMax;
		}
		else if (CurrentPitch < 0.f)
		{
			// Handle when we're aiming down
			AimNode.Aim.Y = float(CurrentPitch) / ViewPitchMin;
			
			if (AimNode.Aim.Y > 0.f)
			{
				AimNode.Aim.Y *= -1.f;
			}
		}
		else
		{
			// Handle when we're aiming straight forward
			AimNode.Aim.Y = 0.f;
		}
	}

	// Update the facing rotation
	FacingRotation.Pitch = 0;
	FacingRotation.Yaw = CurrentYaw;
	FacingRotation.Roll = 0;

	SetRotation(FacingRotation);
}

function bool DoJump(bool bUpdating)
{
	if (bJumpCapable && !bIsCrouched && !bWantsToCrouch && (Physics == PHYS_Walking || Physics == PHYS_Ladder || Physics == PHYS_Spider))
 	{
		if (Physics == PHYS_Spider)
		{
			Velocity = JumpHeight * Floor;
		}
		else if (Physics == PHYS_Ladder)
		{
			Velocity.Z = 0.f;
		}
		else
		{
			Velocity.Z = JumpHeight;
		}

		if (Base != None && !Base.bWorldGeometry && Base.Velocity.Z > 0.f)
		{
			Velocity.Z += Base.Velocity.Z;
		}

		SetPhysics(PHYS_Falling);
		return true;
	}

	return false;
}


//Esta funcao assina a camera isometrica por padrao
simulated function name GetDefaultCameraMode( PlayerController RequestedBy )
{
        return 'Isometric';
}

//Sobrescrevemos este evento para deixar a malha do player visivel todo tempo
simulated event BecomeViewTarget( PlayerController PC )
{
        local UTPlayerController UTPC;

        Super.BecomeViewTarget(PC);

        if (LocalPlayer(PC.Player) != None)
        {
                UTPC = UTPlayerController(PC);
                if (UTPC != None)
                {
                        //Define o PlayerController para traz da visao e deixa a malha do Pawn visivel
                        UTPC.SetBehindView(true);
                        //Remove a mira
                        UTPC.bNoCrosshair = true;
                }
        }
}

//Funca que pega a rotacao do Pawn
simulated singular event Rotator GetBaseAimRotation()
{
        local rotator   POVRot, tempRot;

        tempRot = Rotation;
        tempRot.Pitch = 0;
        SetRotation(tempRot);
        POVRot = Rotation;
        POVRot.Pitch = 0;

        return POVRot;
}

//Inicia o som de passos ao player andar
simulated event playfootstepsound (int footdown)
{
	local SoundCue Footsound;
	Footsound = SoundCue'A_Character_Footsteps.Footsteps.A_Character_Footstep_StoneCue';
	PlaySound(Footsound, false, true,,, true);
}

DefaultProperties
{
        Components.Remove(Sprite)

        Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
                ModShadowFadeoutTime=0.25
                MinTimeBetweenFullUpdates=0.2
                AmbientGlow=(R=.01,G=.01,B=.01,A=1)
                AmbientShadowColor=(R=0.15,G=0.15,B=0.15)
                bSynthesizeSHLight=TRUE
        End Object
        Components.Add(MyLightEnvironment)

        Begin Object Class=SkeletalMeshComponent Name=InitialSkeletalMesh
                CastShadow=true
                bCastDynamicShadow=true
                bOwnerNoSee=false
                LightEnvironment=MyLightEnvironment;
        BlockRigidBody=true;
        CollideActors=true;
        BlockZeroExtent=true;
                PhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
                AnimSets(0)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_AimOffset'
                AnimSets(1)=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale'
                AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
                SkeletalMesh=SkeletalMesh'CH_LIAM_Cathode.Mesh.SK_CH_LIAM_Cathode'
                		bCacheAnimSequenceNodes=false
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=true
		bUpdateKinematicBonesFromAnimation=true
		RBChannel=RBCC_Untitled3
		RBCollideWithChannels=(Untitled3=true)
		bOverrideAttachmentOwnerVisibility=true
		bAcceptsDynamicDecals=false
		bHasPhysicsAssetInstance=true
		TickGroup=TG_PreAsyncWork
		MinDistFactorForKinematicUpdate=0.2f
		bChartDistanceFactor=true
		RBDominanceGroup=20
		Scale=1.f
		bAllowAmbientOcclusion=false
		bUseOnePassLightingOnTranslucency=true
		bPerBoneMotionBlur=true
        End Object

        Mesh=InitialSkeletalMesh;
        Components.Add(InitialSkeletalMesh);
        
        InventoryManagerClass=class'LumDefInventoryManager'
	JumpHeight=420.f
	bCanCrouch=true
	bCanPickupInventory=true

}