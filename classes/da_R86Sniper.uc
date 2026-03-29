//-----------------------------------------------------------
//
//-----------------------------------------------------------
class da_R86Sniper extends da_weapons_Reloadable;

var name            ReloadShortAnim;
var float           ReloadShortRate;
var transient bool  bShortReload;

#exec OBJ LOAD FILE=..\textures\ScopeShaders.utx

var() Material ZoomMat;
var()		int			lenseMaterialID;		// used since material id's seem to change alot
var()		float		scopePortalFOVHigh;		// The FOV to zoom the scope portal by.
var()		float		scopePortalFOV;			// The FOV to zoom the scope portal by.
var()       vector      XoffsetScoped;
var()       vector      XoffsetHighDetail;
// Not sure if these pitch vars are still needed now that we use Scripted Textures. We'll keep for now in case they are. - Ramm 08/14/04
var()		int			scopePitch;				// Tweaks the pitch of the scope firing angle
var()		int			scopeYaw;				// Tweaks the yaw of the scope firing angle
var()		int			scopePitchHigh;			// Tweaks the pitch of the scope firing angle high detail scope
var()		int			scopeYawHigh;			// Tweaks the yaw of the scope firing angle high detail scope
// 3d Scope vars
var   ScriptedTexture   ScopeScriptedTexture;   // Scripted texture for 3d scopes
var	  Shader		    ScopeScriptedShader;   	// The shader that combines the scripted texture with the sight overlay
var   Material          ScriptedTextureFallback;// The texture to render if the users system doesn't support shaders
// new scope vars
var     Combiner            ScriptedScopeCombiner;
var     texture             TexturedScopeTexture;
var	    bool				bInitializedScope;		// Set to true when the scope has been initialized
var		string ZoomMatRef;
var		string ScriptedTextureFallbackRef;

static function PreloadAssets(Inventory Inv, optional bool bSkipRefCount)
{
	super.PreloadAssets(Inv, bSkipRefCount);

	default.ZoomMat = FinalBlend(DynamicLoadObject(default.ZoomMatRef, class'FinalBlend', true));
	default.ScriptedTextureFallback = texture(DynamicLoadObject(default.ScriptedTextureFallbackRef, class'texture', true));

	if ( Crossbow(Inv) != none )
	{
		Crossbow(Inv).ZoomMat = default.ZoomMat;
		Crossbow(Inv).ScriptedTextureFallback = default.ScriptedTextureFallback;
	}
}

static function bool UnloadAssets()
{
	if ( super.UnloadAssets() )
	{
		default.ZoomMat = none;
		default.ScriptedTextureFallback = none;
	}

	return true;
}

exec function pfov(int thisFOV)
{
	if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
		return;

	scopePortalFOV = thisFOV;
}

exec function pPitch(int num)
{
	if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
		return;

	scopePitch = num;
	scopePitchHigh = num;
}

exec function pYaw(int num)
{
	if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
		return;

	scopeYaw = num;
	scopeYawHigh = num;
}

simulated exec function TexSize(int i, int j)
{
	if( !class'ROEngine.ROLevelInfo'.static.RODebugMode() )
		return;

	ScopeScriptedTexture.SetSize(i, j);
}

// Helper function for the scope system. The scope system checks here to see when it should draw the portal.
// if you want to limit any times the portal should/shouldn't be drawn, add them here.
// Ramm 10/27/03
simulated function bool ShouldDrawPortal()
{
//	local 	name	thisAnim;
//	local	float 	animframe;
//	local	float 	animrate;
//
//	GetAnimParams(0, thisAnim,animframe,animrate);

//	if(bUsingSights && (IsInState('Idle') || IsInState('PostFiring')) && thisAnim != 'scope_shoot_last')
    if( bAimingRifle )
		return true;
	else
		return false;
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

    // Get new scope detail value from KFWeapon
    KFScopeDetail = class'KFMod.KFWeapon'.default.KFScopeDetail;

	UpdateScopeMode();
}

// Handles initializing and swithing between different scope modes
simulated function UpdateScopeMode()
{
	if (Level.NetMode != NM_DedicatedServer && Instigator != none && Instigator.IsLocallyControlled() &&
		Instigator.IsHumanControlled() )
    {
	    if( KFScopeDetail == KF_ModelScope )
		{
			scopePortalFOV = default.scopePortalFOV;
			ZoomedDisplayFOV = CalcAspectRatioAdjustedFOV(default.ZoomedDisplayFOV);
			//bPlayerFOVZooms = false;
			if (bAimingRifle)
			{
				PlayerViewOffset = XoffsetScoped;
			}

			if( ScopeScriptedTexture == none )
			{
	        	ScopeScriptedTexture = ScriptedTexture(Level.ObjectPool.AllocateObject(class'ScriptedTexture'));
			}

	        ScopeScriptedTexture.FallBackMaterial = ScriptedTextureFallback;
	        ScopeScriptedTexture.SetSize(512,512);
	        ScopeScriptedTexture.Client = Self;

			if( ScriptedScopeCombiner == none )
			{
				// Construct the Combiner
				ScriptedScopeCombiner = Combiner(Level.ObjectPool.AllocateObject(class'Combiner'));
	            ScriptedScopeCombiner.Material1 = Texture'KF_Weapons5_Scopes_Trip_T.Scope.MilDot';
	            ScriptedScopeCombiner.FallbackMaterial = Shader'ScopeShaders.Zoomblur.LensShader';
	            ScriptedScopeCombiner.CombineOperation = CO_Multiply;
	            ScriptedScopeCombiner.AlphaOperation = AO_Use_Mask;
	            ScriptedScopeCombiner.Material2 = ScopeScriptedTexture;
	        }

			if( ScopeScriptedShader == none )
			{
	            // Construct the scope shader
				ScopeScriptedShader = Shader(Level.ObjectPool.AllocateObject(class'Shader'));
				ScopeScriptedShader.Diffuse = ScriptedScopeCombiner;
				ScopeScriptedShader.SelfIllumination = ScriptedScopeCombiner;
				ScopeScriptedShader.FallbackMaterial = Shader'ScopeShaders.Zoomblur.LensShader';
			}

	        bInitializedScope = true;
		}
		else if( KFScopeDetail == KF_ModelScopeHigh )
		{
			scopePortalFOV = scopePortalFOVHigh;
			ZoomedDisplayFOV = CalcAspectRatioAdjustedFOV(default.ZoomedDisplayFOVHigh);
			//bPlayerFOVZooms = false;
			if (bAimingRifle)
			{
				PlayerViewOffset = XoffsetHighDetail;
			}

			if( ScopeScriptedTexture == none )
			{
	        	ScopeScriptedTexture = ScriptedTexture(Level.ObjectPool.AllocateObject(class'ScriptedTexture'));
	        }
			ScopeScriptedTexture.FallBackMaterial = ScriptedTextureFallback;
	        ScopeScriptedTexture.SetSize(1024,1024);
	        ScopeScriptedTexture.Client = Self;

			if( ScriptedScopeCombiner == none )
			{
				// Construct the Combiner
				ScriptedScopeCombiner = Combiner(Level.ObjectPool.AllocateObject(class'Combiner'));
	            ScriptedScopeCombiner.Material1 = Texture'KF_Weapons5_Scopes_Trip_T.Scope.MilDot';
	            ScriptedScopeCombiner.FallbackMaterial = Shader'ScopeShaders.Zoomblur.LensShader';
	            ScriptedScopeCombiner.CombineOperation = CO_Multiply;
	            ScriptedScopeCombiner.AlphaOperation = AO_Use_Mask;
	            ScriptedScopeCombiner.Material2 = ScopeScriptedTexture;
	        }

			if( ScopeScriptedShader == none )
			{
	            // Construct the scope shader
				ScopeScriptedShader = Shader(Level.ObjectPool.AllocateObject(class'Shader'));
				ScopeScriptedShader.Diffuse = ScriptedScopeCombiner;
				ScopeScriptedShader.SelfIllumination = ScriptedScopeCombiner;
				ScopeScriptedShader.FallbackMaterial = Shader'ScopeShaders.Zoomblur.LensShader';
			}

            bInitializedScope = true;
		}
		else if (KFScopeDetail == KF_TextureScope)
		{
			ZoomedDisplayFOV = CalcAspectRatioAdjustedFOV(default.ZoomedDisplayFOV);
			PlayerViewOffset.X = default.PlayerViewOffset.X;
			//bPlayerFOVZooms = true;

			bInitializedScope = true;
		}
	}
}

simulated event RenderTexture(ScriptedTexture Tex)
{
    local rotator RollMod;

    RollMod = Instigator.GetViewRotation();
    //RollMod.Roll -= 16384;

//	Rpawn = ROPawn(Instigator);
//	// Subtract roll from view while leaning - Ramm
//	if (Rpawn != none && rpawn.LeanAmount != 0)
//	{
//		RollMod.Roll += rpawn.LeanAmount;
//	}

    if(Owner != none && Instigator != none && Tex != none && Tex.Client != none)
        Tex.DrawPortal(0,0,Tex.USize,Tex.VSize,Owner,(Instigator.Location + Instigator.EyePosition()), RollMod,  scopePortalFOV );
}


function float GetAIRating()
{
	local AIController B;

	B = AIController(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return AIRating;

	return (AIRating + 0.0003 * FClamp(1500 - VSize(B.Enemy.Location - Instigator.Location),0,1000));
}

function byte BestMode()
{
	return 0;
}

function bool RecommendRangedAttack()
{
	return true;
}

//TODO: LONG ranged?
function bool RecommendLongRangedAttack()
{
	return true;
}

function float SuggestAttackStyle()
{
	return -1.0;
}


simulated function SetZoomBlendColor(Canvas c)
{
	local Byte    val;
	local Color   clr;
	local Color   fog;

	clr.R = 255;
	clr.G = 255;
	clr.B = 255;
	clr.A = 255;

	if( Instigator.Region.Zone.bDistanceFog )
	{
		fog = Instigator.Region.Zone.DistanceFogColor;
		val = 0;
		val = Max( val, fog.R);
		val = Max( val, fog.G);
		val = Max( val, fog.B);
		if( val > 128 )
		{
			val -= 128;
			clr.R -= val;
			clr.G -= val;
			clr.B -= val;
		}
	}
	c.DrawColor = clr;
}


/**
 * Handles all the functionality for zooming in including
 * setting the parameters for the weapon, pawn, and playercontroller
 *
 * @param bAnimateTransition whether or not to animate this zoom transition
 */
simulated function ZoomIn(bool bAnimateTransition)
{
    super(BaseKFWeapon).ZoomIn(bAnimateTransition);

	bAimingRifle = True;

	if( KFHumanPawn(Instigator)!=None )
		KFHumanPawn(Instigator).SetAiming(True);

	if( Level.NetMode != NM_DedicatedServer && KFPlayerController(Instigator.Controller) != none )
	{
		if( AimInSound != none )
		{
            PlayOwnedSound(AimInSound, SLOT_Interact,,,,, false);
        }
	}
}

/**
 * Handles all the functionality for zooming out including
 * setting the parameters for the weapon, pawn, and playercontroller
 *
 * @param bAnimateTransition whether or not to animate this zoom transition
 */
simulated function ZoomOut(bool bAnimateTransition)
{
    super.ZoomOut(bAnimateTransition);

	bAimingRifle = False;

	if( KFHumanPawn(Instigator)!=None )
		KFHumanPawn(Instigator).SetAiming(False);

	if( Level.NetMode != NM_DedicatedServer && KFPlayerController(Instigator.Controller) != none )
	{
		if( AimOutSound != none )
		{
            PlayOwnedSound(AimOutSound, SLOT_Interact,,,,, false);
        }
        KFPlayerController(Instigator.Controller).TransitionFOV(KFPlayerController(Instigator.Controller).DefaultFOV,0.0);
	}
}

/**
 * Called by the native code when the interpolation of the first person weapon to the zoomed position finishes
 */
simulated event OnZoomInFinished()
{
    local name anim;
    local float frame, rate;

    GetAnimParams(0, anim, frame, rate);

    if (ClientState == WS_ReadyToFire)
    {
        // Play the iron idle anim when we're finished zooming in
        if (anim == IdleAnim)
        {
           PlayIdle();
        }
    }

	if( Level.NetMode != NM_DedicatedServer && KFPlayerController(Instigator.Controller) != none &&
        KFScopeDetail == KF_TextureScope )
	{
		KFPlayerController(Instigator.Controller).TransitionFOV(PlayerIronSightFOV,0.0);
	}
}

simulated event RenderOverlays(Canvas Canvas)
{
    local int m;
	local PlayerController PC;

    if (Instigator == None)
        return;

    // Lets avoid having to do multiple casts every tick - Ramm
	PC = PlayerController(Instigator.Controller);

	if(PC == None)
		return;

    if(!bInitializedScope && PC != none )
	{
    	  UpdateScopeMode();
    }

    // draw muzzleflashes/smoke for all fire modes so idle state won't
    // cause emitters to just disappear
    Canvas.DrawActor(None, false, true); // amb: Clear the z-buffer here

    for (m = 0; m < NUM_FIRE_MODES; m++)
	{
        if (FireMode[m] != None)
        {
            FireMode[m].DrawMuzzleFlash(Canvas);
        }
    }


    SetLocation( Instigator.Location + Instigator.CalcDrawOffset(self) );
    SetRotation( Instigator.GetViewRotation() + ZoomRotInterp);

	PreDrawFPWeapon();	// Laurent -- Hook to override things before render (like rotation if using a staticmesh)

 	if(bAimingRifle && PC != none && (KFScopeDetail == KF_ModelScope || KFScopeDetail == KF_ModelScopeHigh))
 	{
 		if (ShouldDrawPortal())
 		{
			if ( ScopeScriptedTexture != none )
			{
				Skins[LenseMaterialID] = ScopeScriptedShader;
				ScopeScriptedTexture.Client = Self;   // Need this because this can get corrupted - Ramm
				ScopeScriptedTexture.Revision = (ScopeScriptedTexture.Revision +1);
			}
 		}

		bDrawingFirstPerson = true;
 	    Canvas.DrawBoundActor(self, false, false,DisplayFOV,PC.Rotation,rot(0,0,0),Instigator.CalcZoomedDrawOffset(self));
      	bDrawingFirstPerson = false;
	}
    // Added "bInIronViewCheck here. Hopefully it prevents us getting the scope overlay when not zoomed.
    // Its a bit of a band-aid solution, but it will work til we get to the root of the problem - Ramm 08/12/04
	else if( KFScopeDetail == KF_TextureScope && PC.DesiredFOV == PlayerIronSightFOV && bAimingRifle)
	{
		Skins[LenseMaterialID] = ScriptedTextureFallback;

		SetZoomBlendColor(Canvas);

		//Black-out either side of the main zoom circle.
		Canvas.Style = ERenderStyle.STY_Normal;
		Canvas.SetPos(0, 0);
		Canvas.DrawTile(ZoomMat, (Canvas.SizeX - Canvas.SizeY) / 2, Canvas.SizeY, 0.0, 0.0, 8, 8);
		Canvas.SetPos(Canvas.SizeX, 0);
		Canvas.DrawTile(ZoomMat, -(Canvas.SizeX - Canvas.SizeY) / 2, Canvas.SizeY, 0.0, 0.0, 8, 8);

		//The view through the scope itself.
		Canvas.Style = 255;
		Canvas.SetPos((Canvas.SizeX - Canvas.SizeY) / 2,0);
		Canvas.DrawTile(ZoomMat, Canvas.SizeY, Canvas.SizeY, 0.0, 0.0, 1024, 1024);

		//Draw some useful text.
		Canvas.Font = Canvas.MedFont;
		Canvas.SetDrawColor(200,150,0);

		Canvas.SetPos(Canvas.SizeX * 0.16, Canvas.SizeY * 0.43);
		Canvas.DrawText("Zoom: 3.0");

		Canvas.SetPos(Canvas.SizeX * 0.16, Canvas.SizeY * 0.47);
	}
 	else
 	{
		Skins[LenseMaterialID] = ScriptedTextureFallback;
		bDrawingFirstPerson = true;
		Canvas.DrawActor(self, false, false, DisplayFOV);
		bDrawingFirstPerson = false;
 	}
}

//=============================================================================
// Scopes
//=============================================================================

//------------------------------------------------------------------------------
// SetScopeDetail(RO) - Allow the players to change scope detail while ingame.
//	Changes are saved to the ini file.
//------------------------------------------------------------------------------
//simulated exec function SetScopeDetail()
//{
//	if( !bHasScope )
//		return;
//
//	if (KFScopeDetail == KF_ModelScope)
//		KFScopeDetail = KF_TextureScope;
//	else if ( KFScopeDetail == KF_TextureScope)
//		KFScopeDetail = KF_ModelScopeHigh;
//	else if ( KFScopeDetail == KF_ModelScopeHigh)
//		KFScopeDetail = KF_ModelScope;
//
//	AdjustIngameScope();
//	class'KFMod.KFWeapon'.default.KFScopeDetail = KFScopeDetail;
//	class'KFMod.KFWeapon'.static.StaticSaveConfig();		// saves the new scope detail value to the ini
//}

// Adjust a single FOV based on the current aspect ratio. Adjust FOV is the default NON-aspect ratio adjusted FOV to adjust
simulated function float CalcAspectRatioAdjustedFOV(float AdjustFOV)
{
	local KFPlayerController KFPC;
	local float ResX, ResY;
	local float AspectRatio;

	KFPC = KFPlayerController(Level.GetLocalPlayerController());

	if( KFPC == none )
	{
		return AdjustFOV;
	}

	ResX = float(GUIController(KFPC.Player.GUIController).ResX);
	ResY = float(GUIController(KFPC.Player.GUIController).ResY);
	AspectRatio = ResX / ResY;

	if ( KFPC.bUseTrueWideScreenFOV && AspectRatio >= 1.60 ) //1.6 = 16/10 which is 16:10 ratio and 16:9 comes to 1.77
	{
		return CalcFOVForAspectRatio(AdjustFOV);
	}
	else
	{
		return AdjustFOV;
	}
}

//------------------------------------------------------------------------------
// AdjustIngameScope(RO) - Takes the changes to the ScopeDetail variable and
//	sets the scope to the new detail mode. Called when the player switches the
//	scope setting ingame, or when the scope setting is changed from the menu
//------------------------------------------------------------------------------
simulated function AdjustIngameScope()
{
	local PlayerController PC;

    // Lets avoid having to do multiple casts every tick - Ramm
	PC = PlayerController(Instigator.Controller);

	if( !bHasScope )
		return;

	switch (KFScopeDetail)
	{
		case KF_ModelScope:
			if( bAimingRifle )
				DisplayFOV = CalcAspectRatioAdjustedFOV(default.ZoomedDisplayFOV);
			if ( PC.DesiredFOV == PlayerIronSightFOV && bAimingRifle )
			{
            	if( Level.NetMode != NM_DedicatedServer && KFPlayerController(Instigator.Controller) != none )
            	{
                    KFPlayerController(Instigator.Controller).TransitionFOV(KFPlayerController(Instigator.Controller).DefaultFOV,0.0);
}
			}
			break;

		case KF_TextureScope:
			if( bAimingRifle )
				DisplayFOV = CalcAspectRatioAdjustedFOV(default.ZoomedDisplayFOV);
			if ( bAimingRifle && PC.DesiredFOV != PlayerIronSightFOV )
			{
            	if( Level.NetMode != NM_DedicatedServer && KFPlayerController(Instigator.Controller) != none )
            	{
            		KFPlayerController(Instigator.Controller).TransitionFOV(PlayerIronSightFOV,0.0);
            	}
			}
			break;

		case KF_ModelScopeHigh:
			if( bAimingRifle )
			{
				if( ZoomedDisplayFOVHigh > 0 )
				{
					DisplayFOV = CalcAspectRatioAdjustedFOV(default.ZoomedDisplayFOVHigh);
				}
				else
				{
					DisplayFOV = CalcAspectRatioAdjustedFOV(default.ZoomedDisplayFOV);
				}
			}
			if ( bAimingRifle && PC.DesiredFOV == PlayerIronSightFOV )
			{
            	if( Level.NetMode != NM_DedicatedServer && KFPlayerController(Instigator.Controller) != none )
            	{
                    KFPlayerController(Instigator.Controller).TransitionFOV(KFPlayerController(Instigator.Controller).DefaultFOV,0.0);
            	}
			}
			break;
	}

	// Make any chagned to the scope setup
	UpdateScopeMode();
}

simulated event Destroyed()
{
    if (ScopeScriptedTexture != None)
    {
        ScopeScriptedTexture.Client = None;
        Level.ObjectPool.FreeObject(ScopeScriptedTexture);
        ScopeScriptedTexture=None;
    }

    if (ScriptedScopeCombiner != None)
    {
		ScriptedScopeCombiner.Material2 = none;
		Level.ObjectPool.FreeObject(ScriptedScopeCombiner);
		ScriptedScopeCombiner = none;
    }

    if (ScopeScriptedShader != None)
    {
		ScopeScriptedShader.Diffuse = none;
		ScopeScriptedShader.SelfIllumination = none;
		Level.ObjectPool.FreeObject(ScopeScriptedShader);
		ScopeScriptedShader = none;
    }

    Super.Destroyed();
}

simulated function PreTravelCleanUp()
{
    if (ScopeScriptedTexture != None)
    {
        ScopeScriptedTexture.Client = None;
        Level.ObjectPool.FreeObject(ScopeScriptedTexture);
        ScopeScriptedTexture=None;
    }

    if (ScriptedScopeCombiner != None)
    {
		ScriptedScopeCombiner.Material2 = none;
		Level.ObjectPool.FreeObject(ScriptedScopeCombiner);
		ScriptedScopeCombiner = none;
    }

    if (ScopeScriptedShader != None)
    {
		ScopeScriptedShader.Diffuse = none;
		ScopeScriptedShader.SelfIllumination = none;
		Level.ObjectPool.FreeObject(ScopeScriptedShader);
		ScopeScriptedShader = none;
    }
}

// copy-pasted to add (MagCapacity+1) ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
simulated function bool AllowReload()
{
    UpdateMagCapacity(Instigator.PlayerReplicationInfo);

    if( !Instigator.IsHumanControlled() ) {
        return !bIsReloading && MagAmmoRemaining <= MagCapacity && AmmoAmount(0) > MagAmmoRemaining;
    }

    return !( FireMode[0].IsFiring() || FireMode[1].IsFiring() || bIsReloading || ClientState == WS_BringUp
            || MagAmmoRemaining >= MagCapacity + 1 || AmmoAmount(0) <= MagAmmoRemaining
            || (FireMode[0].NextFireTime - Level.TimeSeconds) > 0.1 );
}

exec function ReloadMeNow()
{
    local float ReloadMulti;
        
    if(!AllowReload())
        return;
    if ( bHasAimingMode && bAimingRifle )
    {
        FireMode[1].bIsFiring = False;

        ZoomOut(false);
        if( Role < ROLE_Authority)
            ServerZoomOut(false);
    }
    
    if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
        ReloadMulti = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.GetReloadSpeedModifier(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), self);
    else
        ReloadMulti = 1.0;
        
    bIsReloading = true;
    ReloadTimer = Level.TimeSeconds;
    bShortReload = MagAmmoRemaining > 0;
    if ( bShortReload )
        ReloadRate = Default.ReloadShortRate / ReloadMulti;
    else
        ReloadRate = Default.ReloadRate / ReloadMulti;
        
    if( bHoldToReload )
    {
        NumLoadedThisReload = 0;
    }
    ClientReload();
    Instigator.SetAnimAction(WeaponReloadAnim);
    if ( Level.Game.NumPlayers > 1 && KFGameType(Level.Game).bWaveInProgress && KFPlayerController(Instigator.Controller) != none &&
        Level.TimeSeconds - KFPlayerController(Instigator.Controller).LastReloadMessageTime > KFPlayerController(Instigator.Controller).ReloadMessageDelay )
    {
        KFPlayerController(Instigator.Controller).Speech('AUTO', 2, "");
        KFPlayerController(Instigator.Controller).LastReloadMessageTime = Level.TimeSeconds;
    }
}

simulated function ClientReload()
{
    local float ReloadMulti;
    if ( bHasAimingMode && bAimingRifle )
    {
        FireMode[1].bIsFiring = False;

        ZoomOut(false);
        if( Role < ROLE_Authority)
            ServerZoomOut(false);
    }
    
    if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
        ReloadMulti = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.GetReloadSpeedModifier(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), self);
    else
        ReloadMulti = 1.0;
        
    bIsReloading = true;
    if (MagAmmoRemaining <= 0)
    {
        PlayAnim(ReloadAnim, ReloadAnimRate*ReloadMulti, 0.1);
    }
    else if (MagAmmoRemaining >= 1)
    {
        PlayAnim(ReloadShortAnim, ReloadAnimRate*ReloadMulti, 0.1);
    }

    if( Instigator.Controller.IsA( 'PlayerController' ) )
        PlayerController(Instigator.Controller).endZoom();
}

function AddReloadedAmmo()
{
    local int a;
    
    UpdateMagCapacity(Instigator.PlayerReplicationInfo);

    a = MagCapacity;
    if ( bShortReload )
        a++; // 1 bullet already bolted
    
    if ( AmmoAmount(0) >= a )
        MagAmmoRemaining = a;
    else
        MagAmmoRemaining = AmmoAmount(0);

    // this seems redudant -- PooSH
    // if( !bHoldToReload )
    // {
        // ClientForceKFAmmoUpdate(MagAmmoRemaining,AmmoAmount(0));
    // }

    if ( PlayerController(Instigator.Controller) != none && KFSteamStatsAndAchievements(PlayerController(Instigator.Controller).SteamStatsAndAchievements) != none )
    {
        KFSteamStatsAndAchievements(PlayerController(Instigator.Controller).SteamStatsAndAchievements).OnWeaponReloaded();
    }
}

simulated function BringUp(optional Weapon PrevWeapon)
{
    Super.BringUp(PrevWeapon);

    if ( Instigator.IsLocallyControlled() && ((Mesh!=None) && SelectAnim == 'Ready' && HasAnim('Select')) ) // At this point, go back to the standard Select anim
    {
        SelectAnim = 'Select';
        BringUpTime = 0.33;
    }
}

defaultproperties
{
	//** 3d Scope **//
  	scopePortalFOV=13.33 // 3 X
  	XoffsetScoped = (X=0.0,Y=0.0,Z=0.0)//X=7
  	scopePitch= 0
  	scopeYaw= 0
  	scopePortalFOVHigh=20.000000 // 3.0x
  	ZoomedDisplayFOVHigh=18.000000
  	XoffsetHighDetail = (X=0.0,Y=0.0,Z=0.0)//x=2
  	scopePitchHigh= 0
  	scopeYawHigh= 0
  	KFScopeDetail=KF_ModelScope
  	LenseMaterialID=2
  	bHasScope=true
    bSniping = true
    ScriptedTextureFallbackRef="KF_DA2Weapons.Zoom.Combiner2"//Material'Weapons1st_tex.Zoomscope.LensShader'
    ZoomMatRef="KF_Weapons5_Scopes_Trip_T.M99.MilDotFinalBlend"
	ZoomMat=FinalBlend'KF_Weapons5_Scopes_Trip_T.M99.MilDotFinalBlend'
    TexturedScopeTexture=Texture'KF_Weapons5_Scopes_Trip_T.Scope.MilDot'


    ReloadAnim="reload_empty"
    FireModeClass(0)=Class'KFDA2Weapons.da_R86Fire'
    DisplayFOV=60.000000
    AttachmentClass=Class'KFDA2Weapons.da_R86Attachment'
    ItemName="R86 Sniper Rifle"
	MeshRef="KF_DA2_Weapons.KF_R86_1st"
    Mesh=SkeletalMesh'KF_DA2_Weapons.KF_R86_1st'

    SelectAnim="Ready"
    BringUpTime=1.0
    bHasAimingMode=True
    MagCapacity=6
    ReloadShortRate=1.76
    ReloadShortAnim="Reload"
    ReloadRate=2.34
    ReloadAnimRate=1.000000
    FireModeClass(1)=Class'KFMod.NoFire'
    IdleAnim="Idle"
    IdleAimAnim="Idle"
    PutDownAnim="PutDown"
    SelectSoundRef="KF_M99Snd.M99_Select"
    AIRating=0.200000
    Priority=15
    Description="R86 Sniper Rifle"
    SkinRefs(1)="KF_DA2Weapons.Skins.R86_Final"
    SkinRefs(2)="KF_DA2Weapons.Zoom.Combiner2"
    SleeveNum=0
    FlashBoneName="Muzzle" 
    StandardDisplayFOV=60.0
    PlayerIronSightFOV=40 // Fov of the World in ADS
    ZoomedDisplayFOV=50   // Fov of the Gun in ADS
    WeaponReloadAnim=Reload_M7A3
    Weight=7.0
    bModeZeroCanDryFire=false
    InventoryGroup=4
    GroupOffset=14
    PickupClass=Class'KFDA2Weapons.da_R86Pickup'
    PlayerViewOffset=(X=18.000000,Y=10.000000,Z=-4.000000)
    BobDamping=6.000000
    IconCoords=(X1=434,Y1=253,X2=506,Y2=292)
    HudImage=texture'KF_DA2Weapons.Icons.R86_Unselect'
    SelectedHudImage=texture'KF_DA2Weapons.Icons.R86_Select'
    TraderInfoTexture=texture'KF_DA2Weapons.Icons.R86_Trader'
    HudImageRef="KF_DA2Weapons.Icons.R86_Unselect"
    SelectedHudImageRef="KF_DA2Weapons.Icons.R86_Select"
}
