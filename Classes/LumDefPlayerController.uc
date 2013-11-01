class LumDefPlayerController extends PlayerController;

var LumDefHUD LumDefHUD;

var Vector2D PlayerMouse; //Guarda a posicao 2D do cursor calculada em LumDefHUD
var Actor TraceActor; //Aqui guardamos o nome do actor pego pela funcao trace do click do cursor, caso tenha algum é claro

//Localizacao do cursor e vetores normalizados
var Vector  MouseHitWorldLocation;
var Vector  MouseHitWorldNormal;
var Vector  MousePositionWorldLocation;
var Vector  MousePositionWorldNormal;

//Para onde o pawn estava olhando a ultima vez
var Vector  LastLookLocation;
var vector PawnEyeLocation;

//variaves para ray tracing
var Vector rayDir;
var Vector StartTrace;
var Vector EndTrace;
var float DistanceRemaining;
var bool bPawnNearDestination;

//Variaveis do click do mouse
var bool bLeftMousePressed; //Botao Esquerdo apertado
var bool bRightMousePressed; //Botao Direito apertado
var float totalDeltaTime;
var float ClickSensitivity;

// XP SYSTEM
const MAX_LEVEL = 50;
const XP_INCREMENT = 500; // Amount of XP that is added to the amount of XP required for a level, after each level progression
 
var int XP; // Total amount of gathered XP
var int Level; // Current level
var int XPGatheredForNextLevel; // Amount of XP gathered for the next level
var int XPRequiredForNextLevel; // Amount of XP required for the next level

// STATS SYSTEM
var int StatPoints; // Stat Points Given at level
var int Strength;
var int Dexterity;
var int Intelligence;
var int ManaPower;

// Mouse event enum
enum EMouseEvent
{
  LeftMouseButton,
  RightMouseButton
};


function HandleMouseInput(EMouseEvent MouseEvent, EInputEvent InputEvent)
{
  // Type cast to get our HUD
 LumDefHUD = LumDefHUD(myHUD);

  if (LumDefHUD != None)
  {
    // Detect what kind of input this is
    if (InputEvent == IE_Pressed)
    {
      // Handle pressed event
       switch (MouseEvent)
       {
         case LeftMouseButton:
         LumDefHUD.PendingLeftPressed = true;
         break;

         case RightMouseButton:
         
         break;

         default:

         break;
      }
    }
    else if (InputEvent == IE_Released)
    {
      // Handle released event
      switch (MouseEvent)
      {
         case LeftMouseButton:
         LumDefHUD.PendingLeftReleased = true;
         LumDefHUD.PendingLeftPressed = false;
         break;
         
         case RightMouseButton:
         
         break;

         default:

         break;
      }
    }
  }
}

simulated function PostBeginPlay()
{
        super.postbeginplay();

	// XP SYSTEM
	CalculateLevelProgress();
}

// XP SYSTEM FUNCTIONS BEGIN
// The function that is called from Kismet
public function AddXP(SeqAct_GiveXP action)
{
	GiveXP(action.Amount); // Give the player the amount of XP specified in the Kismet action
}

public function GiveXP(int amount)
{
	XP += amount;

	CalculateLevelProgress();

	while (XPGatheredForNextLevel >= XPRequiredForNextLevel && Level < MAX_LEVEL)
	{
		Level++;
		StatPoints++;
		StatPoints++;
		StatPoints++;
		StatPoints++;
		StatPoints++;
		CalculateAbilitiesProgress();
		// Recalculate level progress after leveling up
		CalculateLevelProgress();
	}
}

private function CalculateAbilitiesProgress()
{
                Strength +=50;
                Dexterity += 50;
                Intelligence += 50;
                ManaPower += 50;
}

private function CalculateLevelProgress()
{
	local int xpToCurrentLevel; // Total amount of XP gathered with current and previous levels
	
	xpToCurrentLevel = 0.5*Level*(Level-1)*XP_INCREMENT;
	XPGatheredForNextLevel = XP - xpToCurrentLevel;
	XPRequiredForNextLevel = Level * XP_INCREMENT;
}
// XP SYSTEM FUNCTIONS END

//funcao tick
event PlayerTick(float DeltaTime)
{
        Super.PlayerTick(DeltaTime);
        
        if(bLeftMousePressed)
        {

        }
        
        if(bRightMousePressed)
	{
		totalDeltaTime += deltaTime;

		SetDestinationPosition(MouseHitWorldLocation);

		if(totalDeltaTime >= ClickSensitivity)
		{
			//Funcao segurar o botao do mouse
			if(!IsInState('MoveMousePressedAndHold'))
                        {
                                `Log("Pushed MoveMousePressedAndHold state");
                                PushState('MoveMousePressedAndHold');
                        }
                        else
                        {
                                //Specify execution of current state, starting from label Begin:, ignoring all events and
                                //keeping our current pushed state MoveMousePressedAndHold. To better understand why this
                                //continually execute each frame from our Begin: label, see
                                //http://udn.epicgames.com/Three/MasteringUnrealScriptStates.html,
                                //11.3 - BASIC STATE TRANSITIONS
                                GotoState('MoveMousePressedAndHold', 'Begin', false, true);
                        }
		}
	}

	if(!isinstate('MoveMouseClick'))
	{
		Pawn.SetRotation(Rotator(LastLookLocation));
	}
}

//Exec function correspondente ao binding StartFire do botao direito e esquerdo quando apertados
exec function StartFire(optional byte FireModeNum)
{
	if(isinstate('MoveMouseClick'))
	{
		PopState(true); //removes all states
	}

	totalDeltaTime = 0; //clear delta timer
	SetDestinationPosition(MouseHitWorldLocation); //sets initial destination of location

	//begin our  target, this lets us know we are starting again
	bPawnNearDestination = false;

	// Initialise for the mouse over time funtionality
	bLeftMousePressed = FireModeNum == 0;
	bRightMousePressed = FireModeNum == 1;

	//for debug purposes - maybe call another function from here?
	if(bLeftMousePressed) `Log("Left Mouse Pressed");
	if(bRightMousePressed) `Log("Right Mouse Pressed");
}

//Exec function correspondente ao binging StopFire do botao esquerdo e direito quando soltos
exec function Stopfire(optional byte FiremodeNum )
{
	if(bLeftMousePressed && FiremodeNum == 0)
	{
		bLeftMousePressed = false;
		`log("left mouse released");
	}
	if(bRightMousePressed && FiremodeNum == 1)
	{
		bRightMousePressed = false;
	}

	if(!bPawnNearDestination && totalDeltaTime < ClickSensitivity)
	{
		if(fastTrace(MouseHitWorldLocation, PawnEyeLocation,, true))
			{
				MovePawnToDestination();
			}
	}
	else
	{
	//	PopState();
	}

	if(bPawnNearDestination){PopState();}

	totalDeltaTime = 0;
}

//Funcao MovePawnToDestination aqui
function MovePawnToDestination()
{
	SetDestinationPosition(MouseHitWorldLocation);
	PushState('MoveMouseClick');
}


//Aqui comecao os estados de movimento
state MoveMouseClick
{
	event PoppedState()
	{
		if(IsTimerActive(nameof(StopLingering)))
		{
			ClearTimer(nameof(StopLingering));
		}
	}

	event PushedState()
	{
		SetTimer(3, false, nameof(StopLingering));
		if (Pawn != none)
		{
			Pawn.SetMovementPhysics();
		}
	}


Begin:
	while(!bpawnNearDestination)
	{
		MoveTo(GetdestinationPosition());
	}
	PopState();

}

state MoveMousePressedAndHold
{
Begin:
        while(!bPawnNearDestination)
        {
                `Log("MoveMousePressedAndHold at pos"@GetDestinationPosition());
                MoveTo(GetDestinationPosition());


		}

                PopState();
}

function StopLingering()
{

	`Log("Stopped Lingering");
	PopState(true);
}

//Controla a funcao do movimento do player no cenario
function PlayerMove(float deltatime)
{
	local Vector PawnXYLocation; //where our pawn is
	local Vector DestinationXYLocation; //where it is going to be
	local Vector Destination;
	local Vector2D DistanceCheck; //see how far it is away

	super.PlayerMove(deltatime);

	Destination = GetDestinationPosition();
	DistanceCheck.X = Destination.X - Pawn.Location.X;
	DistanceCheck.Y = Destination.Y - Pawn.Location.Y;

	//calculate the remaining distance using pythagorean theorum :D
	DistanceRemaining = Sqrt((DistanceCheck.X*DistanceCheck.X) + (DistanceCheck.Y*DistanceCheck.Y));

	//are we close?
	bPawnNearDestination = DistanceRemaining < 50.0f;

	//update our location locally with our pawns location
	PawnXYLocation.X = Pawn.Location.X;
	PawnXYLocation.Y = Pawn.Location.Y;

	DestinationXYLocation.X = GetDestinationPosition().X;
	DestinationXYLocation.Y = GetDestinationPosition().Y;

	//face the right direction
	LastLookLocation = DestinationXYLocation - PawnXYLocation;
	Pawn.SetRotation(Rotator(DestinationXYLocation - PawnXYLocation));
}


/*Sobrescrevo a funcao UpdateRotation da classe mae apenas para
 deixar a rotacao da camera estatica enquanto se move o mouse*/
function UpdateRotation(float DeltaTime);

//overwrite camera adjust from key presses
function ProcessViewRotation(float DeltaTime, out rotator out_ViewRotation, rotator DeltaRot){//
}

DefaultProperties
{
        //Definimos nossa propria classe Camera
        CameraClass=class'LumDefGame.LumDefCamera'
        //Definimous nossa propria classe PlayerInput
        InputClass=class'LumDefGame.LumDefPlayerInput'
        //Definimos um valor padrao para a sensivilidade do click
        ClickSensitivity = 0.20f

        // XP SYSTEM
	Level = 1;
	XP = 0;

	// STATS SYSTEM
	StatPoints = 0;
	Strength = 0;
	Dexterity = 0;
	Intelligence = 0;
	ManaPower = 0;
}