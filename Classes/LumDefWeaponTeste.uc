class LumDefWeaponTeste extends LumDefWeapon;

defaultproperties
{
        Begin Object Name=PickupMesh
                SkeletalMesh=SkeletalMesh'WP_RocketLauncher.Mesh.SK_WP_RocketLauncher_3P'
        End Object

        AttachmentClass=class'UTGameContent.UTAttachment_RocketLauncher'
        WeaponFireTypes(0)=EWFT_Projectile
        WeaponFireTypes(1)=EWFT_Projectile
        WeaponProjectiles(0)=class'UTProj_Rocket'
        WeaponProjectiles(1)=class'UTProj_Rocket'
        AmmoCount=30
        MaxAmmoCount=30
}