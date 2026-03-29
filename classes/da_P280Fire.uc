//-----------------------------------------------------------
//
//-----------------------------------------------------------
class da_P280Fire extends da_BasicFire;

defaultproperties
{
     MuzEmitterClass=Class'KFDA2Weapons.da_XD40Muzzle3rd'
     FlashEmitterClass=Class'KFDA2Weapons.da_XD40Muzzle3rd'
     DamageType=Class'KFDA2Weapons.da_damtypes_p280Pistol'
     DamageMin=35
     DamageMax=115 //50 OG
     MaxPenetrations=2 // Added for KF
     PenDmgReduction=0.75 // Added for KF
     Momentum=20000.000000
     TransientSoundVolume=2.200000
     TransientSoundRadius=250.000000
     FireAnim="Fire"
     FireAnimRate=1.0
     FireSound=Sound'DA2_WeaponSounds.Gunshots.P280_Fire'
     StereoFireSoundRef="DA2_WeaponSounds.Gunshots.P280_Fire"
     NoAmmoSound=Sound'KF_9MMSnd.9mm_DryFire'
     FireRate=0.25
     AmmoClass=Class'KFDA2Weapons.da_P280Ammo'
     ShakeRotMag=(X=75.000000,Y=75.000000,Z=400.000000)
     ShakeRotRate=(X=12500.000000,Y=12500.000000,Z=10000.000000)
     ShakeRotTime=3.500000
     ShakeOffsetMag=(X=-6.000000,Y=1.000000,Z=8.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000)
     ShakeOffsetTime=2.500000
     BotRefireRate=0.200000
     Spread=0.012000

     ShellEjectClass=class'KFDA2Weapons.da_ShellEjectPistol'
     ShellEjectBoneName=Shell_Ejector
     bRandomPitchFireSound=false
     FireAimedAnim=Fire
     bPawnRapidFireAnim=True
     bAttachSmokeEmitter=True
     RecoilRate=0.07
     maxVerticalRecoilAngle=500
     maxHorizontalRecoilAngle=100
     TweenTime=0.025
     AmmoPerFire=1
     SpreadStyle=SS_Random
     bWaitForRelease=true
}