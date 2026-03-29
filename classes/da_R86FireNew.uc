class da_R86FireNew extends M99Fire;

var()           class<Emitter>  ShellEjectClass;            // class of the shell eject emitter
var()           Emitter         ShellEjectEmitter;          // The shell eject emitter
var()           name            ShellEjectBoneName;         // name of the shell eject bone

var() class<Emitter> MuzEmitterClass;
var() Emitter MuzEmitter;

// I could fix this in blender but I'm lazy maybe later - Waffle
simulated function PostNetBeginPlay()
{
    local rotator r;

    r.pitch=-16384;
    weapon.SetBoneRotation('Muzzle', r, 0, 1.f);
}

simulated function InitEffects()
{
    super.InitEffects();

    // don't even spawn on server
    if ( (Level.NetMode == NM_DedicatedServer) || (AIController(Instigator.Controller) != None) )
		return;

    if ( (MuzEmitterClass != None) && ((MuzEmitter == None) || MuzEmitter.bDeleteMe) )
    {
        MuzEmitter = Weapon.Spawn(MuzEmitterClass);
    }
    if ( (SmokeEmitterClass != None) && ((SmokeEmitter == None) || SmokeEmitter.bDeleteMe) )
    {
        SmokeEmitter = Weapon.Spawn(SmokeEmitterClass);
    }

    if ( MuzEmitter != None )
		Weapon.AttachToBone(MuzEmitter, 'Muzzle');

    // don't even spawn on server
    if ( (Level.NetMode == NM_DedicatedServer) || (AIController(Instigator.Controller) != None) )
		return;
    if ( (ShellEjectClass != None) && ((ShellEjectEmitter == None) || ShellEjectEmitter.bDeleteMe) )
    {
        ShellEjectEmitter = Weapon.Spawn(ShellEjectClass);
        Weapon.AttachToBone(ShellEjectEmitter, ShellEjectBoneName);
    }
}

function DrawMuzzleFlash(Canvas Canvas)
{
    super.DrawMuzzleFlash(Canvas);
    // Draw shell ejects
    if (ShellEjectEmitter != None )
    {
        Canvas.DrawActor( ShellEjectEmitter, false, false, Weapon.DisplayFOV );
    }

    if (MuzEmitter != None && MuzEmitter.Base != Weapon)
    {
        MuzEmitter.SetLocation( Weapon.GetEffectStart() );
        Canvas.DrawActor( MuzEmitter, false, false, Weapon.DisplayFOV );
    }
}

simulated function DestroyEffects()
{
    if (MuzEmitter != None)
        MuzEmitter.Destroy();

    super.DestroyEffects();

    if (ShellEjectEmitter != None)
        ShellEjectEmitter.Destroy();
}

function FlashMuzzleFlash()
{
    super.FlashMuzzleFlash();
    if (MuzEmitter != None)
        MuzEmitter.SpawnParticle(1);

    if (ShellEjectEmitter != None)
    {
        ShellEjectEmitter.Trigger(Weapon, Instigator);
    }
}

//event ModeDoFire()
//{
//	super.modedofire();
//			
//		if (Instigator.Owner != none && Owner != none)
//		{
//			if (da_SteamStatsAndAchievements(da_Players_PlayerController(Instigator.Owner).SteamStatsAndAchievements).Sniper2Completed) 
//				FireRate=1.30;
//			else if (da_SteamStatsAndAchievements(da_Players_PlayerController(Instigator.Owner).SteamStatsAndAchievements).Sniper1Completed) 
//				FireRate=1.65;
//			else 
//				FireRate=2.00; 
//		}
//}

function ServerPlayFiring()
{
    Weapon.PlayOwnedSound(FireSound,SLOT_None,TransientSoundVolume,,TransientSoundRadius,0.95+(frand()*0.1),false);
    Weapon.PlayOwnedSound(Sound'DA2_WeaponSounds.Gunshots.R86_Fire',SLOT_None,TransientSoundVolume/3,,TransientSoundRadius*15,0.95+(frand()*0.1),false);
}

function PlayFiring()
{
	if ( Weapon.Mesh != none && FireCount > 0 )
	{
		if ( Weapon.HasAnim(FireLoopAnim) )
			Weapon.PlayAnim(FireLoopAnim, FireLoopAnimRate, 0.0);
		else
			Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
	}
	else
		Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);

    Weapon.PlayOwnedSound(FireSound,SLOT_None,TransientSoundVolume,,TransientSoundRadius,0.95+(frand()*0.1),false);
    Weapon.PlayOwnedSound(Sound'DA2_WeaponSounds.Gunshots.R86_Fire',SLOT_None,TransientSoundVolume/3,,TransientSoundRadius*15,0.95+(frand()*0.1),false);

    ClientPlayForceFeedback(FireForce);
    FireCount++;
}

defaultproperties
{
     MuzEmitterClass=Class'KFDA2Weapons.da_R86Muzzle1st'
     bFiringDoesntAffectMovement=true
     ProjSpawnOffset=(X=25.000000,Y=5.000000,Z=-6.000000)
     bWaitForRelease=True
     TransientSoundVolume=3.400000
     TransientSoundRadius=500.000000
     FireSound=Sound'DA2_WeaponSounds.Gunshots.R86_Fire'
     FiresoundRef="DA2_WeaponSounds.Gunshots.R86_Fire"
     FireRate=0.6 //1.3 //2.000000
     AmmoClass=Class'KFDA2Weapons.da_R86Ammo'
     AmmoPerFire=1
     ShakeRotMag=(X=100.000000,Y=100.000000,Z=100.000000)
     ShakeRotRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeRotTime=2.500000
     ShakeOffsetMag=(X=-7.600000,Y=5.000000,Z=10.500000)
     ShakeOffsetTime=1.700000
     ProjectileClass=Class'KFDA2Weapons.da_proj_Sniper'
     BotRefireRate=0.980000
     FlashEmitterClass=Class'KFDA2Weapons.da_R86Muzzle1st' //Class'ROEffects.MuzzleFlash1stSTG'
     aimerror=1.000000
     Spread=0.750000

     FireAnim="Fire"
     FireAnimRate=1.0
     StereoFireSoundRef="DA2_WeaponSounds.Gunshots.R86_Fire"
     NoAmmoSound=Sound'KF_9MMSnd.9mm_DryFire'
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
     SpreadStyle=SS_Random
}
