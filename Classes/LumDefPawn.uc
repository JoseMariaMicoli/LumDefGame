class LumDefPawn extends GamePawn;

simulated function PostBeginPlay()
{
        Super.PostBeginPlay();
        `Log("\n\nLumDefPawn its up!\n");
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
        End Object

        Mesh=InitialSkeletalMesh;
        Components.Add(InitialSkeletalMesh);
}