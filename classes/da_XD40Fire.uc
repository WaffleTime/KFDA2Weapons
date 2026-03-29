//-----------------------------------------------------------
//
//-----------------------------------------------------------
class da_XD40Fire extends da_BasicFire;

defaultproperties
{
     MuzEmitterClass=Class'KFDA2Weapons.da_XD40Muzzle3rd'
     FlashEmitterClass=Class'KFDA2Weapons.da_XD40Muzzle3rd'
     //FireSoundFar=Sound'DA2_WeaponSounds.Gunshots.XD40_FireFar'
     DamageType=Class'KFDA2Weapons.da_damtypes_XD40Pistol'
     DamageMin=21
     DamageMax=35 //29 OG
     Momentum=10500.000000
     TransientSoundVolume=2.000000
     TransientSoundRadius=250.000000
     FireAnim="Fire"
     FireAnimRate=1.5 //1.75
     FireSound=Sound'DA2_WeaponSounds.Gunshots.XD40_Fire'
     StereoFireSoundRef="DA2_WeaponSounds.Gunshots.XD40_Fire"
     NoAmmoSound=Sound'KF_9MMSnd.9mm_DryFire'
     FireRate=0.175000
     AmmoClass=Class'KFDA2Weapons.da_XD40Ammo'
     ShakeRotMag=(X=75.000000,Y=75.000000,Z=250.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=3.000000
     ShakeOffsetMag=(X=-6.000000,Y=3.000000,Z=10.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000)
     ShakeOffsetTime=2.000000
     BotRefireRate=0.350000
     Spread=0.015000

     ShellEjectClass=class'KFDA2Weapons.da_ShellEjectPistol'
     ShellEjectBoneName=Shell_Ejector
     bRandomPitchFireSound=false
     FireAimedAnim=Fire
     bPawnRapidFireAnim=True
     bAttachSmokeEmitter=True
     RecoilRate=0.07
     maxVerticalRecoilAngle=300
     maxHorizontalRecoilAngle=50
     TweenTime=0.025
     AmmoPerFire=1
     SpreadStyle=SS_Random
     bWaitForRelease=true
}