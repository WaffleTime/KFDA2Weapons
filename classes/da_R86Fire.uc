//-----------------------------------------------------------
//
//-----------------------------------------------------------
class da_R86Fire extends da_BasicFire;

var int	tracesPerShot;
var Projectile Tracer;

function DoFireEffect() {
	local int i;

	for (i = 0; i < tracesPerShot; i++)
		super.DoFireEffect();
}

defaultproperties
{
     tracesPerShot=1
     MuzEmitterClass=Class'KFDA2Weapons.da_R86Muzzle1st'
     HitSFXVolume=1.000000
     HitDecal=Class'KFDA2Weapons.da_effects_LongBulletHole'
     //HeadshotChance=1.000000
     //DamageTypeHeadShot=Class'KFDA2Weapons.da_damtypes_SniperHeadshot'
     //FireSoundFar=Sound'DA2_WeaponSounds.R86_FireFar'
     //FireSoundRand=0.150000
     DamageType=Class'KFDA2Weapons.da_damtypes_Sniper'
     DamageMin=5 //90
     DamageMax=210 //130
     Momentum=6500.000000
     TransientSoundVolume=3.400000
     TransientSoundRadius=500.000000
     FireSound=Sound'DA2_WeaponSounds.Gunshots.R86_Fire'
     FireForce="AssaultRifleFire"
     FireRate=0.6 //1.3 //2.300000
     AmmoClass=Class'KFDA2Weapons.da_R86Ammo_SR'
     ShakeRotMag=(X=100.000000,Y=100.000000,Z=100.000000)
     ShakeRotRate=(X=2500.000000,Y=2500.000000,Z=2500.000000)
     ShakeRotTime=2.500000
     ShakeOffsetMag=(X=-15.000000,Y=10.000000,Z=25.000000)
     ShakeOffsetTime=2.000000
     BotRefireRate=0.980000
     Spread=0.003000

     FlashEmitterClass=Class'KFDA2Weapons.da_R86Muzzle1st'
     MaxPenetrations=3 // Added for KF
     PenDmgReduction=0.90 // Added for KF
     FireAnim="Fire"
     FireAnimRate=1.0
     StereoFireSoundRef="DA2_WeaponSounds.Gunshots.R86_Fire"
     NoAmmoSoundRef="KF_SCARSnd.SCAR_DryFire"
     ShellEjectClass=class'KFDA2Weapons.da_ShellEjectRifle'
     ShellEjectBoneName=Shell_Ejector
     bRandomPitchFireSound=false
     FireAimedAnim=Fire
     bPawnRapidFireAnim=True
     bAttachSmokeEmitter=True
     RecoilRate=0.1
     maxVerticalRecoilAngle=500
     maxHorizontalRecoilAngle=100
     TweenTime=0.025
     AmmoPerFire=1
     SpreadStyle=SS_Random
     bWaitForRelease=true
}
