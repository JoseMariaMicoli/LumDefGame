class LumDefCamera extends Camera;

/*Sobrescrevemos esta funcao da classe mae Camera apenas para mudar os valores das variaveis
porem o resto fica praticamente identica a funcao da classe mae*/
function UpdateViewTarget(out TViewTarget OutVT, float DeltaTime)
{
        local vector            Loc, Pos, HitLocation, HitNormal;
        local rotator           Rot;
        local Actor                     HitActor;
        local CameraActor       CamActor;
        local bool                      bDoNotApplyModifiers;
        local TPOV                      OrigPOV;

        // store previous POV, in case we need it later
        OrigPOV = OutVT.POV;

        // Default FOV on viewtarget
        OutVT.POV.FOV = DefaultFOV;

        // Viewing through a camera actor.
        CamActor = CameraActor(OutVT.Target);
        if( CamActor != None )
        {
                CamActor.GetCameraView(DeltaTime, OutVT.POV);

                // Grab aspect ratio from the CameraActor.
                bConstrainAspectRatio   = bConstrainAspectRatio || CamActor.bConstrainAspectRatio;
                OutVT.AspectRatio               = CamActor.AspectRatio;

                // See if the CameraActor wants to override the PostProcess settings used.
                CamOverridePostProcessAlpha = CamActor.CamOverridePostProcessAlpha;
                CamPostProcessSettings = CamActor.CamOverridePostProcess;
        }
        else
        {
                // Give Pawn Viewtarget a chance to dictate the camera position.
                // If Pawn doesn't override the camera view, then we proceed with our own defaults
                if( Pawn(OutVT.Target) == None || !Pawn(OutVT.Target).CalcCamera(DeltaTime, OutVT.POV.Location, OutVT.POV.Rotation, OutVT.POV.FOV) )
                {
                        // don't apply modifiers when using these debug camera modes.
                        bDoNotApplyModifiers = TRUE;

                        switch( CameraStyle )
                        {
                                case 'Fixed'                    :       // do not update, keep previous camera position by restoring
                                       // saved POV, in case CalcCamera changes it but still returns false
                                        OutVT.POV = OrigPOV;
                                        break;

                                case 'ThirdPerson'      : // Simple third pers on view implementation
                                case 'FreeCam'          :
                                case 'FreeCam_Default':
                                        Loc = OutVT.Target.Location;
                                        Rot = OutVT.Target.Rotation;

                                        //OutVT.Target.GetActorEyesViewPoint(Loc, Rot);
                                        if( CameraStyle == 'FreeCam' || CameraStyle == 'FreeCam_Default' )
                                        {
                                                Rot = PCOwner.Rotation;
                                        }
                                        Loc += FreeCamOffset >> Rot;

                                        Pos = Loc - Vector(Rot) * FreeCamDistance;
                                        // @fixme, respect BlockingVolume.bBlockCamera=false
                                        HitActor = Trace(HitLocation, HitNormal, Pos, Loc, FALSE, vect(12,12,12));
                                        OutVT.POV.Location = (HitActor == None) ? Pos : HitLocation;
                                        OutVT.POV.Rotation = Rot;
                                        break;

                                case 'Isometric':
                                        // fix Camera rotation
                                        Rot.Pitch = (-55.0f     *DegToRad) * RadToUnrRot;
                                        Rot.Roll =  (0          *DegToRad) * RadToUnrRot;
                                        Rot.Yaw =   (30.0f      *DegToRad) * RadToUnrRot;

                                        Loc.X = PCOwner.Pawn.Location.X - 64;
                                        Loc.Y = PCOwner.Pawn.Location.Y - 64;
                                        Loc.Z = PCOwner.Pawn.Location.Z + 156;

                                        Pos = Loc - Vector(Rot) * FreeCamDistance;

                                        OutVT.POV.Location = Pos;
                                        OutVT.POV.Rotation = Rot;
                                        break;

                                case 'FirstPerson'      : // Simple first person, view through viewtarget's 'eyes'
                                default                         :       OutVT.Target.GetActorEyesViewPoint(OutVT.POV.Location, OutVT.POV.Rotation);
                                        break;

                        }
                }
        }

        if( !bDoNotApplyModifiers )
        {
                // Apply camera modifiers at the end (view shakes for example)
                ApplyCameraModifiers(DeltaTime, OutVT.POV);
        }
        //`log( WorldInfo.TimeSeconds  @ GetFuncName() @ OutVT.Target @ OutVT.POV.Location @ OutVT.POV.Rotation @ OutVT.POV.FOV );
}

DefaultProperties
{
        DefaultFOV=90.f
}