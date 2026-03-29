//-----------------------------------------------------------
// Basic DA2 Weapon that can be reloaded.
// Coded by Dante
// Edited/Updated by aBsOlUt.
//-----------------------------------------------------------
class da_weapons_Reloadable extends KFWeapon;

#EXEC OBJ LOAD FILE= KF_DA2_Weapons.ukx

var() name Idle1; //Idle animation 1 (Fidgit1)
var() name Idle2; //Idle animation 2 (Fidgit2)
var() float LastFidgitTime;

//Time
var() float TweenTime;

simulated function PlayIdle()
{
    super.PlayIdle();
    if (ClientState == WS_ReadyToFire && !bIsReloading && !bAimingRifle && LastFidgitTime<Level.TimeSeconds) 
    {
        LastFidgitTime = Level.TimeSeconds + 25 + frand() * 15; //* 5
        if (frand() < 0.5 && hasAnim(Idle1))
            playAnim(Idle1, ReloadAnimRate, TweenTime);
        else if (hasAnim(Idle2))
            playAnim(Idle2, ReloadAnimRate, TweenTime);
    }
}

// Thank you Mr. UT developer guy to place a "no timer running with clientstate"
// in NATIVE code for weapons to distract us mod authors...
/*simulated function Timer() {

//If he is not moving or doing anything weapon related play idle anims
    if (ClientState == WS_ReadyToFire && !bAimingRifle) {
        if (frand() < 0.5 && hasAnim(Idle1))
            playAnim(Idle1, ReloadAnimRate, TweenTime);
        else if (hasAnim(Idle2))
            playAnim(Idle2, ReloadAnimRate, TweenTime);
        setTimer(25 + frand() * 5, false);
    } else if (ClientState == WS_PutDown)
        setTimer(0.2, false);
    else
        setTimer(0, false);

    if (allowDirectPutDown()) {
        super.Timer();
    }
}

simulated function bool allowDirectPutDown()
{
    return !( (FireMode[0].bIsFiring) || (FireMode[1].bIsFiring) ||
        (!IsInState(name) && !isInState('Hidden'))) || ClientState == WS_BringUp;
}

//Checks
simulated function bool isWeaponReady()
{
  return !(!allowDirectPutDown() || bIsReloading ||
			ClientState != WS_ReadyToFire && Level.netMode == NM_Client);
}

simulated function bool PutDown() {
    if (allowDirectPutDown())
        return super.putDown();
    else if (ClientState == WS_BringUp || ClientState == WS_ReadyToFire) {
        clientState = WS_PutDown;
        setTimer(0.1, true);
    }

    return true;
}*/

defaultproperties
{
     Idle1="Fidgit1"
     Idle2="Fidgit2"
     TweenTime=0.150000
     ReloadAnimRate=1.000000
}
