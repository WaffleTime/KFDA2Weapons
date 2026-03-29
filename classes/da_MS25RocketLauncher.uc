// ============================================================================
//	DA2.da_weapons_MS25RocketLauncher:
//	By: aBsOlUt, Dante
//  Thanks to: Epic for their RocketLauncher barrel code.
// ============================================================================

class da_MS25RocketLauncher extends da_weapons_Reloadable;

//=============================================================================
// Variables
//=============================================================================

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

var() Material ZoomMat;

static function PreloadAssets(Inventory Inv, optional bool bSkipRefCount)
{
	super.PreloadAssets(Inv, bSkipRefCount);

	default.ZoomMat = FinalBlend(DynamicLoadObject(default.ZoomMatRef, class'FinalBlend', true));
	default.ScriptedTextureFallback = texture(DynamicLoadObject(default.ScriptedTextureFallbackRef, class'texture', true));

	if ( da_MS25RocketLauncher(Inv) != none )
	{
		da_MS25RocketLauncher(Inv).ZoomMat = default.ZoomMat;
		da_MS25RocketLauncher(Inv).ScriptedTextureFallback = default.ScriptedTextureFallback;
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
        if (KFScopeDetail == KF_TextureScope) {
            KFScopeDetail = KF_ModelScopeHigh;
        }

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
		else /*( KFScopeDetail == KF_ModelScopeHigh )*/
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
		//else if (KFScopeDetail == KF_TextureScope)
		//{
		//	ZoomedDisplayFOV = CalcAspectRatioAdjustedFOV(default.ZoomedDisplayFOV);
		//	PlayerViewOffset.X = default.PlayerViewOffset.X;
		//	//bPlayerFOVZooms = true;
//
		//	bInitializedScope = true;
		//}
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

/*simulated function ReloadSound()
{
    if (AmmoAmount(0) >= 1)
    {
	PlaySound(ReloadM99,,0.5);
	}
	else
	{
	return;
	}
}*/

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

	//if( Level.NetMode != NM_DedicatedServer && KFPlayerController(Instigator.Controller) != none &&
    //    KFScopeDetail == KF_TextureScope )
	//{
	//	KFPlayerController(Instigator.Controller).TransitionFOV(PlayerIronSightFOV,0.0);
	//}
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
	//else if( KFScopeDetail == KF_TextureScope && PC.DesiredFOV == PlayerIronSightFOV && bAimingRifle)
	//{
	//	Skins[LenseMaterialID] = ScriptedTextureFallback;
	//	
	//	SetZoomBlendColor(Canvas);
	//	
	//	//Black-out either side of the main zoom circle.
	//	Canvas.Style = ERenderStyle.STY_Normal;
	//	Canvas.SetPos(0, 0);
	//	Canvas.DrawTile(ZoomMat, (Canvas.SizeX - Canvas.SizeY) / 2, Canvas.SizeY, 0.0, 0.0, 8, 8);
	//	Canvas.SetPos(Canvas.SizeX, 0);
	//	Canvas.DrawTile(ZoomMat, -(Canvas.SizeX - Canvas.SizeY) / 2, Canvas.SizeY, 0.0, 0.0, 8, 8);
	//	
	//	//The view through the scope itself.
	//	Canvas.Style = 255;
	//	Canvas.SetPos((Canvas.SizeX - Canvas.SizeY) / 2,0);
	//	Canvas.DrawTile(ZoomMat, Canvas.SizeY, Canvas.SizeY, 0.0, 0.0, 1024, 1024);
	//	
	//	//Draw some useful text.
	//	Canvas.Font = Canvas.MedFont;
	//	Canvas.SetDrawColor(200,150,0);
	//	
	//	Canvas.SetPos(Canvas.SizeX * 0.16, Canvas.SizeY * 0.43);
	//	Canvas.DrawText("Zoom: 3.0");
	//	
	//	Canvas.SetPos(Canvas.SizeX * 0.16, Canvas.SizeY * 0.47);
	//}
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
/*simulated exec function SetScopeDetail()
{
	if( !bHasScope )
		return;

	if (KFScopeDetail == KF_ModelScope)
		KFScopeDetail = KF_TextureScope;
	else if ( KFScopeDetail == KF_TextureScope)
		KFScopeDetail = KF_ModelScopeHigh;
	else if ( KFScopeDetail == KF_ModelScopeHigh)
		KFScopeDetail = KF_ModelScope;

	AdjustIngameScope();
	class'KFMod.KFWeapon'.default.KFScopeDetail = KFScopeDetail;
	class'KFMod.KFWeapon'.static.StaticSaveConfig();		// saves the new scope detail value to the ini
}*/

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
			//if( bAimingRifle )
			//	DisplayFOV = CalcAspectRatioAdjustedFOV(default.ZoomedDisplayFOV);
			//if ( bAimingRifle && PC.DesiredFOV != PlayerIronSightFOV )
			//{
            //	if( Level.NetMode != NM_DedicatedServer && KFPlayerController(Instigator.Controller) != none )
            //	{
            //		KFPlayerController(Instigator.Controller).TransitionFOV(PlayerIronSightFOV,0.0);
            //	}
			//}
			//break;

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

state PendingClientWeaponSet
{
    simulated function Timer()
    {
        if ( Pawn(Owner) != None && !bIsReloading )
        {
            ClientWeaponSet(bPendingSwitch);
        }

        if ( IsInState('PendingClientWeaponSet') )
        {
			SetTimer(0.1, false);
		}
    }

    simulated function BeginState()
    {
        SetTimer(0.1, false);
    }

    simulated function EndState()
    {
    }
}

// ============================================================================ Gay Scope Stuff Above

//var float BarrelRotation;
//var float FinalRotation;
//
//const NUM_BARRELS = 4;
//const BARREL_ROTATION_RATE = 2.95;
//
//var bool bRotateBarrel;
//
//function bool RecommendLongRangedAttack()
//{
//	return true;
//}
//
//simulated function PlayFiring()
//{
//        GotoState('AnimateLoad', 'Begin');
//}
//// ============================================================================
//
//simulated function RotateBarrel()
//{
//    FinalRotation += 65535.0 / NUM_BARRELS;
//    if (FinalRotation >= 65535.0)
//    {
//        FinalRotation -= 65535.0;
//        BarrelRotation -= 65535.0;
//    }
//    bRotateBarrel = true;
//}
//
//simulated function UpdateBarrel(float dt)
//{
//    local Rotator R;
//
//    BarrelRotation += dt * 65535.0 * BARREL_ROTATION_RATE / NUM_BARRELS;
//    if (BarrelRotation > FinalRotation)
//    {
//        BarrelRotation = FinalRotation;
//        bRotateBarrel = false;
//    }
//
//    R.Yaw = BarrelRotation;
//    SetBoneRotation('Drum', R, 0, 1.0);
//}
//
//simulated state AnimateLoad extends BusyState
//{
//    simulated function Tick(float dt)
//    {
//        if (bRotateBarrel)
//            UpdateBarrel(dt);
//    }
//
//Begin:
//    Sleep(1.10);
//    RotateBarrel();
//    Sleep(0.10);
//    //PlayOwnedSound(Sound'WeaponSounds.RocketLauncher.RocketLauncherLoad', SLOT_None,,,,,false);
//    ClientPlayForceFeedback( "RocketLauncherLoad" );
//    Sleep(0.30);
//    GotoState('');
//}
//
//function float SuggestAttackStyle()
//{
//	local float EnemyDist;
//
//	// recommend backing off if target is too close
//	EnemyDist = VSize(Instigator.Controller.Enemy.Location - Owner.Location);
//	if ( EnemyDist < 750 )
//	{
//		if ( EnemyDist < 500 )
//			return -1.5;
//		else
//			return -0.7;
//	}
//	else if ( EnemyDist > 1600 )
//		return 0.5;
//	else
//		return -0.1;
//}
//
//function float GetAIRating() {
//
//    local Bot B;
//
//	B = Bot(Instigator.Controller);
//
//	if ( B == None )
//		return 0.1;
//
//	if ( B.Enemy == None )
//	{
//		if ( (da_objective_Destroyable(B.Target) != None) && !da_objective_Destroyable(B.Target).bDisabled)
//			return 1.0;
//	}
//
//	if (da_turrets_Turret(B.Enemy) != none)
//	   return 1.0;
//
//    return 0.1;
//
//}

// ============================================================================

defaultproperties
{
    //** 3d Scope **//
    scopePortalFOV=20
    XoffsetScoped = (X=0.0,Y=0.0,Z=0.0)
    scopePitch= 0
    scopeYaw= 0
    scopePortalFOVHigh=20.000000
    ZoomedDisplayFOVHigh=70.000000
    XoffsetHighDetail = (X=0.0,Y=0.0,Z=0.0)
    scopePitchHigh= 0
    scopeYawHigh= 0
    KFScopeDetail=KF_ModelScope
    lenseMaterialID=2
    bHasScope=true
    CustomCrosshair=11
    CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross5"
    ScriptedTextureFallbackRef="KF_Weapons_Trip_T.CBLens_cmb"
    ZoomMatRef="KF_Weapons5_Scopes_Trip_T.M99.MilDotFinalBlend"
    ZoomMat=FinalBlend'KF_Weapons5_Scopes_Trip_T.M99.MilDotFinalBlend'

    Idle2="Fidgit1"
    FireModeClass(0)=Class'KFDA2Weapons.da_MS25Fire'
    //FireModeClass(1)=Class'KFDA2Weapons.da_MS25FireGuided' // No clue how this works
    FireModeClass(1)=Class'KFMod.NoFire'
    AIRating=0.800000
    DisplayFOV=70.000000
    StandardDisplayFOV=70.0
    PlayerIronSightFOV=70 // Fov of the World in ADS
    ZoomedDisplayFOV=75 //60 Fov of the GUN in ADS
    InventoryGroup=4
    GroupOffset=22
    AttachmentClass=Class'KFDA2Weapons.da_MS25Attachment'
    ItemName="MS-25 Rocket Launcher"
    Description="MS-25 Rocket Launcher."
	MeshRef="KF_DA2_Weapons.KF_MS25_1st"
    Mesh=SkeletalMesh'KF_DA2_Weapons.KF_MS25_1st'
    Skins(1)=Shader'KF_DA2Weapons.Skins.MS25_Final'
    Skins(2)=Combiner'KF_DA2Weapons.Zoom.Combiner2'
    SleeveNum=0
    FlashBoneName="Muzzle"
    ReloadRate=3.6
    ReloadAnim="Reload"
    bHasAimingMode=True
    MagCapacity=4
    IdleAnim="Idle"
    IdleAimAnim="Idle_Iron"
	PutDownAnim="PutDown"
    Priority=20
    WeaponReloadAnim=Reload_IJC_SealSqueal
    Weight=7.0
    PickupClass=Class'KFDA2Weapons.da_MS25Pickup'
    PlayerViewOffset=(X=8.000000,Y=10.000000,Z=-2.000000)
    IconCoords=(X1=169,Y1=172,X2=245,Y2=208)
    HudImage=texture'KF_DA2Weapons.Icons.MS25_Unselect'
    SelectedHudImage=texture'KF_DA2Weapons.Icons.MS25_Select'
	HudImageRef="KF_DA2Weapons.Icons.MS25_Unselect"
    SelectedHudImageRef="KF_DA2Weapons.Icons.MS25_Select"
    TraderInfoTexture=texture'KF_DA2Weapons.Icons.MS25_Trader'
}
