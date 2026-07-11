// ============================================================================
//	KFDA2Weapons.da_weapons_BasicFire:
//	By: aBsOlUt, Dante, Leviathan
// ============================================================================
class da_BasicFire extends ScrnFire;

var() class<Emitter> MuzEmitterClass;
var() Emitter MuzEmitter;

var sound RicochetSFX[2], MaterialSFX[20];
var float HitSFXVolume, HitFXChance;
var class<emitter> HitFx, MaterialFX[20];
var class<ProjectedDecal> HitDecal;

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
}

function DrawMuzzleFlash(Canvas Canvas)
{
    super.DrawMuzzleFlash(canvas);

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
}

function FlashMuzzleFlash()
{
    super.FlashMuzzleFlash();
    if (MuzEmitter != None)
        MuzEmitter.SpawnParticle(1);
}

//Old DoTrace - Possibly causing crashes
/*function DoTrace(Vector Start, Rotator Dir)
{
	local Vector X,Y,Z, End, HitLocation, HitNormal, ArcEnd;
	local Actor Other;
	local KFWeaponAttachment WeapAttach;
	local array<int>	HitPoints;
	local KFPawn HitPawn;
    local int Damage;
    local material surface;

	MaxRange();

	Weapon.GetViewAxes(X, Y, Z);
	if ( Weapon.WeaponCentered() )
		ArcEnd = (Instigator.Location + Weapon.EffectOffset.X * X + 1.5 * Weapon.EffectOffset.Z * Z);
	else ArcEnd = (Instigator.Location + Instigator.CalcDrawOffset(Weapon) + Weapon.EffectOffset.X * X + Weapon.Hand * Weapon.EffectOffset.Y * Y +
		 Weapon.EffectOffset.Z * Z);

	X = Vector(Dir);
	End = Start + TraceRange * X;
	Other = Instigator.HitPointTrace(HitLocation, HitNormal, End, HitPoints, Start,, 1);

	if ( Other != None && Other != Instigator && Other.Base != Instigator )
	{
        WeapAttach = KFWeaponAttachment(Weapon.ThirdPersonActor);
        SpawnHitEffects(other, surface, hitlocation, rotator(hitnormal));

		if ( !Other.bWorldGeometry )
		{
			// Update hit effect except for pawns
			if ( !Other.IsA('Pawn') && !Other.IsA('HitScanBlockingVolume') &&
                !Other.IsA('ExtendedZCollision') )
			{
				if( WeapAttach!=None )
				{
                    WeapAttach.UpdateHit(Other, HitLocation, HitNormal);
                }
			}

			HitPawn = KFPawn(Other);
		}
		else
		{
			HitLocation = HitLocation + 2.0 * HitNormal;
            if ( WeapAttach != None )
			{
				WeapAttach.UpdateHit(Other,HitLocation,HitNormal);
			}
		}
	}
	else
	{
		HitLocation = End;
		HitNormal = Normal(Start - End);
	}
    Super(ScrnFire).DoTrace(Start,Dir);
}*/

function DoTrace(Vector Start, Rotator Dir)
{
    local Vector X,Y,Z, End, HitLocation, HitNormal, ArcEnd;
    local Actor Other;
    local byte HitCount, PenCounter;
    local float HitDamage, HitMomentum;
    local array<int> HitPoints;
    local array<Actor> IgnoreActors;
    local KFPawn HitPawn;
    local KFMonster Zed;
    local int i;
    local bool bWasDecapitated;
    local material surface;

    KillCountPerTrace = 0;

    MaxRange();

    Weapon.GetViewAxes(X, Y, Z);
    if ( Weapon.WeaponCentered() ) {
        ArcEnd = (Instigator.Location + Weapon.EffectOffset.X * X + 1.5 * Weapon.EffectOffset.Z * Z);
    }
    else {
        ArcEnd = (Instigator.Location + Instigator.CalcDrawOffset(Weapon) + Weapon.EffectOffset.X * X +
        Weapon.Hand * Weapon.EffectOffset.Y * Y + Weapon.EffectOffset.Z * Z);
    }

    X = Vector(Dir);
    End = Start + TraceRange * X;
    HitDamage = DamageMax;
    HitMomentum = Momentum;

    // HitCount isn't a number of max penetration. It is just to be sure we won't stuck in infinite loop
    while( ++HitCount < 127 && HitDamage >= DamageMin )
    {
        Zed = none;
        HitPawn = none;

        Other = Instigator.HitPointTrace(HitLocation, HitNormal, End, HitPoints, Start,, 1);
        if( Other == none ) {
            break;
        }
        else if( Other==Instigator || Other.Base == Instigator ) {
            IgnoreActors[IgnoreActors.Length] = Other;
            Other.SetCollision(false);
            Start = HitLocation;
            continue;
        }
        else if ( Other.bWorldGeometry || Other == Level ) {
            if( KFWeaponAttachment(Weapon.ThirdPersonActor) != None )
                KFWeaponAttachment(Weapon.ThirdPersonActor).UpdateHit(Other,HitLocation,HitNormal);
                SpawnHitEffects(other, surface, hitlocation, rotator(hitnormal)); // Not sure where the optimal place to put this
            break;
        }

        Zed = KFMonster(Other);
        if ( Zed != none ) {
            IgnoreActors[IgnoreActors.Length] = Other;
            Other.SetCollision(false);
            SpawnHitEffects(other, surface, hitlocation, rotator(hitnormal)); // Not sure where the optimal place to put this
        }
        else if( ExtendedZCollision(Other) != none && Other.Owner != none ) {
            IgnoreActors[IgnoreActors.Length] = Other;
            IgnoreActors[IgnoreActors.Length] = Other.Owner;
            Other.SetCollision(false);
            Other.Owner.SetCollision(false);
            Zed = KFMonster(Other.Owner);
            SpawnHitEffects(other, surface, hitlocation, rotator(hitnormal)); // Not sure where the optimal place to put this
        }
        else {
            HitPawn = KFPawn(Other);
            SpawnHitEffects(other, surface, hitlocation, rotator(hitnormal)); // Not sure where the optimal place to put this
        }

        if (HitPawn != none) {
            if(!HitPawn.bDeleteMe) {
                 HitPawn.ProcessLocationalDamage(int(HitDamage), Instigator, HitLocation, HitMomentum*X,DamageType,
                        HitPoints);
            }
            IgnoreActors[IgnoreActors.Length] = Other;
            IgnoreActors[IgnoreActors.Length] = HitPawn.AuxCollisionCylinder;
            Other.SetCollision(false);
            HitPawn.AuxCollisionCylinder.SetCollision(false);
        }
        else if (Zed != none) {
            bWasDecapitated = Zed.bDecapitated;
            AdjustZedDamage(Zed, HitDamage);
            Zed.TakeDamage(HitDamage, Instigator, HitLocation, HitMomentum*X, DamageType);
            if (Zed == none || Zed.Health <= 0 || (!bWasDecapitated && Zed.bDecapitated)) {
                ++KillCountPerTrace;
            }
            else if (Zed != none && PenDmgReductionByHealth > 0) {
                HitDamage *= 1.0 - PenDmgReductionByHealth * Zed.Health;
                HitMomentum *= 1.0 - PenDmgReductionByHealth * Zed.Health;
            }
        }
        else {
            Other.TakeDamage(HitDamage, Instigator, HitLocation, HitMomentum*X, DamageType);
            //This breaks the penetration mechanic, the very thing that this class was made for??? Hello??
            //break;
        }

        if (++PenCounter > MaxPenetrations)
            break;

        HitDamage *= PenDmgReduction;
        HitMomentum *= PenDmgReduction;
        Start = HitLocation;
    }

    // Turn the collision back on for any actors we turned it off
    for (i = 0; i < IgnoreActors.Length; ++i) {
        if (IgnoreActors[i] != none) {
            IgnoreActors[i].SetCollision(true);
        }
    }
}

function da_effects_HitHack hackSpawn(Class<Actor> c, vector hitL, rotator hitN) {
    local da_effects_HitHack t;

    t = spawn(class'da_effects_HitHack',,, hitL, hitN);
    if (t != none)
        t.hitClass = c;
    return t;
}

function SpawnHitEffects(actor other, material surface, vector hitlocation, rotator hitnormal)
{
    local int matType;
    local Actor FX;

    if(vehicle(other)!=none) matType=3;
    else if(pawn(other)!=none) matType=6;
    else if(surface!=none) matType=surface.SurfaceType;
	
	if( Other.IsA('KFMonster') || Other.IsA('ExtendedZCollision') )
		matType = 6;

    fx = hackSpawn(HitFX, hitlocation, hitnormal);

    if(frand()<hitfxchance)
    {
        if(hitDecal!=none)
            hackSpawn(hitDecal, hitlocation-vector(hitnormal)*2, rotator(-vector(hitNormal)));

        if(hitFX!=none && fx!=none)
            if(frand()<0.075 || ((mattype==3 || mattype==15) && frand()<0.3)) {
                FX.PlaySound(RicochetSFX[rand(2)],SLOT_None,HitSFXVolume*1.2,,175,0.9+frand()*0.2);
                hackSpawn(class'KFDA2Weapons.da_effects_BulletHitRicochet',hitLocation, hitnormal);
            }
            else {
                FX.PlaySound(MaterialSFX[matType],SLOT_None,HitSFXVolume,,175,0.9+frand()*0.2);
                if(MaterialFX[matType]!=none)
                    hackSpawn(MaterialFX[matType],hitLocation, hitnormal);
            }
    }
}

defaultproperties
{
    MaxPenetrations=0 // Change on weapon
    PenDmgReduction=0.0 // Change on weapon
    PenDmgReductionByHealth=0.0  //0.0005 zed with 100 hp remaining reduces the following damage by 5%
    DamageMin=10  // the bullet cannot over-penetrate the body if its leftover damage is lower than DamageMin

    RicochetSFX(0)=Sound'DA2_Various.HitSounds.BulletRicochet'
    RicochetSFX(1)=Sound'DA2_Various.HitSounds.BulletRicochet2'
    MaterialSFX(0)=Sound'DA2_Various.HitSounds.BulletHit'
    MaterialSFX(1)=Sound'DA2_Various.HitSounds.BulletHitStone'
    MaterialSFX(2)=Sound'DA2_Various.HitSounds.bullethitdirt'
    MaterialSFX(3)=Sound'DA2_Various.HitSounds.bullethitmetal'
    MaterialSFX(4)=Sound'DA2_Various.HitSounds.bullethitwood'
    MaterialSFX(5)=Sound'DA2_Various.HitSounds.bullethitdirt'
    MaterialSFX(6)=Sound'DA2_Various.HitSounds.BulletHitFlesh'
    MaterialSFX(7)=Sound'DA2_Various.HitSounds.BulletHitStone'
    MaterialSFX(8)=Sound'DA2_Various.HitSounds.BulletHitSand'
    MaterialSFX(10)=Sound'DA2_Various.HitSounds.bullethitglass'
    MaterialSFX(11)=Sound'DA2_Various.HitSounds.bullethitdirt'
    MaterialSFX(12)=Sound'DA2_Various.HitSounds.BulletHitStone'
    MaterialSFX(13)=Sound'DA2_Various.HitSounds.bullethitwood'
    MaterialSFX(14)=Sound'DA2_Various.HitSounds.bullethitdirt'
    MaterialSFX(15)=Sound'DA2_Various.HitSounds.bullethitmetal'
    MaterialSFX(16)=Sound'DA2_Various.HitSounds.bullethitwood'
    MaterialSFX(17)=Sound'DA2_Various.HitSounds.BulletHitSand'
    MaterialSFX(18)=Sound'DA2_Various.HitSounds.bullethitdirt'
    MaterialSFX(19)=Sound'DA2_Various.HitSounds.bullethitdirt'
    HitSFXVolume=0.750000
    HitFXChance=1.000000
    HitFx=Class'KFDA2Weapons.da_effects_BulletHit'
    MaterialFX(0)=Class'KFDA2Weapons.da_effects_BulletHitRock'
    MaterialFX(1)=Class'KFDA2Weapons.da_effects_BulletHitRock'
    MaterialFX(2)=Class'KFDA2Weapons.da_effects_BulletHitDirt'
    MaterialFX(3)=Class'KFDA2Weapons.da_effects_BulletHitMetal'
    MaterialFX(4)=Class'KFMod.WoodHitEmitter'
    MaterialFX(5)=Class'KFDA2Weapons.da_effects_BulletHitDirt'
    MaterialFX(6)=Class'KFDA2Weapons.da_effects_BulletHitFlesh'
    MaterialFX(7)=Class'KFDA2Weapons.da_effects_BulletHitSnow'
    MaterialFX(8)=Class'KFDA2Weapons.da_effects_BulletHitSnow'
    MaterialFX(10)=Class'KFMod.GlassHitEmitter'
    MaterialFX(11)=Class'KFDA2Weapons.da_effects_BulletHitDirt'
    MaterialFX(12)=Class'KFDA2Weapons.da_effects_BulletHitRock'
    MaterialFX(13)=Class'KFMod.WoodHitEmitter'
    MaterialFX(14)=Class'KFDA2Weapons.da_effects_BulletHitDirt'
    MaterialFX(15)=Class'KFDA2Weapons.da_effects_BulletHitMetal'
    MaterialFX(16)=Class'KFMod.WoodHitEmitter'
    MaterialFX(17)=Class'KFDA2Weapons.da_effects_BulletHitDirt'
    MaterialFX(18)=Class'KFDA2Weapons.da_effects_BulletHitDirt'
    MaterialFX(19)=Class'KFDA2Weapons.da_effects_BulletHitDirt'
    HitDecal=Class'KFDA2Weapons.da_effects_BulletHole'
    //HeadShotDamageMult=2.000000
    //AmmoClass=Class'da2.da_weapons_Ammo'
}
