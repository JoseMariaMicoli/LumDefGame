class LumDefHUD extends HUD;

//Armazena a textura que representa o cursor na tela
var const Texture2D CursorTexture;
//Armazena a cor do cursor
var const Color CursorColor;
//Estamos usando ScaleForm?
var bool UsingScaleForm;
//variavel pronta para cast de LumDefCursorGFx
var LumDefCursorGFx LumDefCursorGFx;

// Pending left mouse button pressed event
var bool PendingLeftPressed;
// Pending left mouse button released event
var bool PendingLeftReleased;
// Pending right mouse button pressed event
var bool PendingRightPressed;
// Pending right mouse button released event
var bool PendingRightReleased;
// Pending middle mouse button pressed event
var bool PendingMiddlePressed;
// Pending middle mouse button released event
var bool PendingMiddleReleased;
// Pending mouse wheel scroll up event
var bool PendingScrollUp;
// Pending mouse wheel scroll down event
var bool PendingScrollDown;
// Cached mouse world origin
var Vector CachedMouseWorldOrigin;
// Cached mouse world direction
var Vector CachedMouseWorldDirection;
// Last mouse interaction interface
var LumDefMouseInteractionInterface LastMouseInteractionInterface;

simulated event PostBeginPlay()
{
        //Executamos o mesmo evento da classe mae
        Super.PostBeginPlay();

        //Testamos se UsingScaleForm retorna True
        if (UsingScaleForm)
        {
                LumDefCursorGFx = new () class'LumDefCursorGFx';
                //Testamos se temos uma instancia valida de LumDefCursorGFx
                if (LumDefCursorGFx != None)
                {
                        LumDefCursorGFx.LumDefHUD = Self;
                        LumDefCursorGFx.SetTimingMode(TM_Game);

                        //Executamos a funcao Init de LumDefCursorGFx para iniciar o ScaleForm
                        LumDefCursorGFx.Init(class'Engine'.static.GetEngine().GamePlayers[LumDefCursorGFx.LocalPlayerOwnerIndex]);
                }
        }
}

function DrawBar(String  Title, float Value, float MaxValue,int X, int Y, int R, int G, int B) // Create our function used to draw bars
{
	local int PosX; //Declare our variable representing our postition on the X-axis
	local int BarSizeX; //Declare our variable representing the size of our bar

	PosX = X; //Where we should draw the rectangle
	BarSizeX = 300 * FMin(Value / MaxValue, 1); // size of active rectangle (change 300 to however big you want your bar to be)
 
	//Displays active rectangle
	Canvas.SetPos(PosX,Y);
	Canvas.SetDrawColor(R, G, B, 200);
	Canvas.DrawRect(BarSizeX, 12);

	//Displays empty rectangle
	Canvas.SetPos(BarSizeX+X,Y);
	Canvas.SetDrawColor(255, 255, 255, 80);
	Canvas.DrawRect(300 - BarSizeX, 12); //Change 300 to however big you want your bar to be

	//Draw our title
	Canvas.SetPos(PosX+300+5, Y); //Change 300 to however big your bar is
	Canvas.SetDrawColor(R, G, B, 200);
	Canvas.Font = class'Engine'.static.GetSmallFont();
	Canvas.DrawText(Title);

} 

// Unordered Functions Called Elsewhere
function CheckViewPortAspectRatio()
{
        local vector2D ViewportSize;
	local bool bIsWideScreen;
        local PlayerController PC;

        foreach LocalPlayerControllers(class'PlayerController', PC)
	{
		LocalPlayer(PC.Player).ViewportClient.GetViewportSize(ViewportSize);
		break;
	}
        
        bIsWideScreen = (ViewportSize.Y > 0.f) && (ViewportSize.X/ViewportSize.Y > 1.7);

        if ( bIsWideScreen )
	{
		RatioX = SizeX / 1280.f;
	        RatioY = SizeY / 720.f;
	}
}


function DrawHud()
{
	local LumDefPlayerController PC;
	PC = LumDefPlayerController(PlayerOwner);

	CheckViewPortAspectRatio();

	//If player is not dead or spectating... ( you could also use DrawLivingHud() )
	if ( !PlayerOwner.IsDead() )
	{



		DrawBar("Stat Points:"@PC.StatPoints,PC.StatPoints,PC.StatPoints,20,600,80,80,80); // Stat Points Unspent

		DrawBar("Strength:"@PC.Strength,PC.Strength,PC.Strength,20,480,80,80,80); // Total Strength
		DrawBar("Dexterity:"@PC.Dexterity,PC.Dexterity,PC.Dexterity,20,500,80,80,80); // Total Dexterity
		DrawBar("Intelligence:"@PC.Intelligence,PC.Intelligence,PC.Intelligence,20,520,80,80,80); // Total Intelligence
		DrawBar("ManaPower:"@PC.ManaPower,PC.ManaPower,PC.ManaPower,20,540,80,80,80); //Total ManaPower

		DrawBar("Health:"@PlayerOwner.Pawn.Health$"%",PlayerOwner.Pawn.Health, PlayerOwner.Pawn.HealthMax,20,620,200,80,80); //...draw our health-bar
		DrawBar("Level:"@PC.Level, PC.Level, PC.MAX_LEVEL ,20,640,80,80,80); //...and our level-bar
		if ( PC.Level != PC.MAX_LEVEL ) //If our player hasn't reached the highest level...
		{
			DrawBar("XP:"@PC.XPGatheredForNextLevel$"/"$PC.XPRequiredForNextLevel, PC.XPGatheredForNextLevel, PC.XPRequiredForNextLevel, 20, 660, 80, 255, 80); //...draw our XP-bar
		}
	}
}

//evento que é chamado quando o HUD é destruido e se encarrega de fechar o ScaleForm Movie
simulated event Destroyed()
{
        Super.Destroyed();

        if (LumDefCursorGFx != None)
        {
                LumDefCursorGFx.Close(True);
                LumDefCursorGFx = None;
        }
}

//Esta funcao se encarrega de ver se o tamanho da tela mundou e passar essas mudanças para o ScaleForm
function PreCalcValues()
{
        Super.PreCalcValues();
        
        if (LumDefCursorGFx != None)
        {
                LumDefCursorGFx.SetViewport(0, 0, SizeX, SizeY);
                LumDefCursorGFx.SetViewScaleMode(SM_NoScale);
                LumDefCursorGFx.SetAlignment(Align_TopLeft);
        }
}

//Sobrescrevemos o evento PostRender() da classe mae que atualiza o HUD a cada Tick
event PostRender()
{
        //Variavel pronta para fazer cast a LumDefPlayerInput
        local LumDefPlayerInput LumDefPlayerInput;
        //Instancias locais de LumDefCamera e LumDefPlayerController prontas para type cast
	local LumDefCamera PlayerCam;
        local LumDefPlayerController LumDefPlayerController;
        local LumDefMouseInteractionInterface MouseInteractionInterface;
        local Vector HitLocation, HitNormal;

        Super.PostRender();

        //Aseguramos que nao usamos scaleform e que temos uma textura valida para o cursor
        if (!UsingScaleForm && CursorTexture != None)
        {
                //Aseguramos que temos um PlayerOwner valido
                if (PlayerOwner != None)
                {
                         //Fazemos o cast de LumDefPlayerInput
                        LumDefPlayerInput = LumDefPlayerInput(PlayerOwner.PlayerInput);
                        
                        //Com este teste garantimos que temos uma instacia valida de LumDefPlayerInput
                        if (LumDefPlayerInput != None)
                        {
                                //Definimos a posicao do canvas para a posicao do cursor do mouse
                                Canvas.SetPos(LumDefPlayerInput.MousePosition.X, LumDefPlayerInput.MousePosition.Y);
                                //Definimos a cor do cursor
                                Canvas.DrawColor = CursorColor;
                                //Finalmente pintamos a textura do cursor na tela
                                Canvas.DrawTile(CursorTexture, CursorTexture.SizeX, CursorTexture.SizeY, 0.f, 0.f, CursorTexture.SizeX, CursorTexture.SizeY,, True);
                        }
                }
        }


        //Type cast de player controller aqui
	LumDefPlayerController = LumDefPlayerController(PlayerOwner);
	LumDefPlayerController.PlayerMouse = GetMouseCoordinates();

	//Canvas.DeProject das cordenadas 2D do cursor
	Canvas.DeProject(LumDefPlayerController.Playermouse, LumDefPlayerController.MousePositionWorldLocation, LumDefPlayerController.MousePositionWorldNormal);

	//Type cast de LumDefCamera aqui
	Playercam = LumDefCamera(LumDefPlayerController.PlayerCamera);

	//Calcula a variacao da posicao do cursor
	//Definimos a direcao do raio para mouseWorldnormal
	LumDefPlayerController.rayDir = LumDefPlayerController.MousePositionWorldNormal;

	//Iniciamos o trace para a player camera(Isometrica) + 100 unidades em z e uma correcao no frente da camera de (direction *10)
	LumDefPlayerController.StartTrace = (PlayerCam.ViewTarget.POV.Location + Vect(0,0,100)) + LumDefPlayerController.raydir * 10;

	//Finalizamos este raio no inicio +  direção multiplicada pela distância determinada(5000 unidade é o suficiente em geral)
	LumDefPlayerController.endtrace = LumDefPlayerController.StartTrace + LumDefPlayerController.Raydir * 5000;

	//E feito o traco a cada frame para verificar sobre qual objeto do senario o jogador clico com cursor atravez do exec startfire (MouseWorldLocation aqui)
	LumDefPlayerController.TraceActor = trace(LumDefPlayerController.MouseHitWorldLocation, LumDefPlayerController.MouseHitWorldNormal,
	LumDefPlayerController.EndTrace, LumDefPlayerController.StartTrace, true);

	//Calcula o pawn eye location para debugar o raio e para verificar se a obstaculos no local clicado
	LumDefPlayerController.PawnEyeLocation = Pawn(PlayerOwner.ViewTarget).Location +
	Pawn(PlayerOwner.ViewTarget).EyeHeight * Vect(0,0,1);

        // Get the current mouse interaction interface
  MouseInteractionInterface = GetMouseActor(HitLocation, HitNormal);

  // Handle mouse over and mouse out
  // Did we previously had a mouse interaction interface?
  if (LastMouseInteractionInterface != None)
  {
    // If the last mouse interaction interface differs to the current mouse interaction
    if (LastMouseInteractionInterface != MouseInteractionInterface)
    {
      // Call the mouse out function
      LastMouseInteractionInterface.MouseOut(CachedMouseWorldOrigin, CachedMouseWorldDirection);
      // Assign the new mouse interaction interface
      LastMouseInteractionInterface = MouseInteractionInterface; 

      // If the last mouse interaction interface is not none
      if (LastMouseInteractionInterface != None)
      {
        // Call the mouse over function
        LastMouseInteractionInterface.MouseOver(CachedMouseWorldOrigin, CachedMouseWorldDirection); // Call mouse over
      }
    }
  }
  else if (MouseInteractionInterface != None)
  {
    // Assign the new mouse interaction interface
    LastMouseInteractionInterface = MouseInteractionInterface; 
    // Call the mouse over function
    LastMouseInteractionInterface.MouseOver(CachedMouseWorldOrigin, CachedMouseWorldDirection); 
  }

  if (LastMouseInteractionInterface != None)
  {
    // Handle left mouse button
    if (PendingLeftPressed)
    {
      if (PendingLeftReleased)
      {
        // This is a left click, so discard
        PendingLeftPressed = false;
        PendingLeftReleased = false;
      }
      else
      {
        // Left is pressed
        PendingLeftPressed = false;
        LastMouseInteractionInterface.MouseLeftPressed(CachedMouseWorldOrigin, CachedMouseWorldDirection, HitLocation, HitNormal);
      }
    }
    else if (PendingLeftReleased)
    {
      // Left is released
      PendingLeftReleased = false;
      LastMouseInteractionInterface.MouseLeftReleased(CachedMouseWorldOrigin, CachedMouseWorldDirection);
    }

    // Handle right mouse button
    if (PendingRightPressed)
    {
      if (PendingRightReleased)
      {
        // This is a right click, so discard
        PendingRightPressed = false;
        PendingRightReleased = false;
      }
      else
      {
        // Right is pressed
        PendingRightPressed = false;
        LastMouseInteractionInterface.MouseRightPressed(CachedMouseWorldOrigin, CachedMouseWorldDirection, HitLocation, HitNormal);
      }
    }
    else if (PendingRightReleased)
    {
      // Right is released
      PendingRightReleased = false;
      LastMouseInteractionInterface.MouseRightReleased(CachedMouseWorldOrigin, CachedMouseWorldDirection);
    }

    // Handle middle mouse button
    if (PendingMiddlePressed)
    {
      if (PendingMiddleReleased)
      {
        // This is a middle click, so discard 
        PendingMiddlePressed = false;
        PendingMiddleReleased = false;
      }
      else
      {
        // Middle is pressed
        PendingMiddlePressed = false;
        LastMouseInteractionInterface.MouseMiddlePressed(CachedMouseWorldOrigin, CachedMouseWorldDirection, HitLocation, HitNormal);
      }
    }
    else if (PendingMiddleReleased)
    {
      PendingMiddleReleased = false;
      LastMouseInteractionInterface.MouseMiddleReleased(CachedMouseWorldOrigin, CachedMouseWorldDirection);
    }

    // Handle middle mouse button scroll up
    if (PendingScrollUp)
    {
      PendingScrollUp = false;
      LastMouseInteractionInterface.MouseScrollUp(CachedMouseWorldOrigin, CachedMouseWorldDirection);
    }

    // Handle middle mouse button scroll down
    if (PendingScrollDown)
    {
      PendingScrollDown = false;
      LastMouseInteractionInterface.MouseScrollDown(CachedMouseWorldOrigin, CachedMouseWorldDirection);
    }
  }

        //draw our hud
	DrawHUD();

	super.PostRender();
}

function LumDefMouseInteractionInterface GetMouseActor(optional out Vector HitLocation, optional out Vector HitNormal)
{
  local LumDefMouseInteractionInterface MouseInteractionInterface;
  local LumDefPlayerInput LumDefPlayerInput;
  local Vector2D MousePosition;
  local Actor HitActor;

  // Ensure that we have a valid canvas and player owner
  if (Canvas == None || PlayerOwner == None)
  {
    return None;
  }

  // Type cast to get the new player input
  LumDefPlayerInput = LumDefPlayerInput(PlayerOwner.PlayerInput);

  // Ensure that the player input is valid
  if (LumDefPlayerInput == None)
  {
    return None;
  }

  // We stored the mouse position as an IntPoint, but it's needed as a Vector2D
  MousePosition.X = LumDefPlayerInput.MousePosition.X;
  MousePosition.Y = LumDefPlayerInput.MousePosition.Y;
  // Deproject the mouse position and store it in the cached vectors
  Canvas.DeProject(MousePosition, CachedMouseWorldOrigin, CachedMouseWorldDirection);

  // Perform a trace actor interator. An interator is used so that we get the top most mouse interaction
  // interface. This covers cases when other traceable objects (such as static meshes) are above mouse
  // interaction interfaces.
  ForEach TraceActors(class'Actor', HitActor, HitLocation, HitNormal, CachedMouseWorldOrigin + CachedMouseWorldDirection * 65536.f, CachedMouseWorldOrigin,,, TRACEFLAG_Bullet)
  {
    // Type cast to see if the HitActor implements that mouse interaction interface
    MouseInteractionInterface = LumDefMouseInteractionInterface(HitActor);
    if (MouseInteractionInterface != None)
    {
      return MouseInteractionInterface;
    }
  }

  return None;
}

function Vector GetMouseWorldLocation()
{
  local LumDefPlayerInput LumDefPlayerInput;
  local Vector2D MousePosition;
  local Vector MouseWorldOrigin, MouseWorldDirection, HitLocation, HitNormal;

  // Ensure that we have a valid canvas and player owner
  if (Canvas == None || PlayerOwner == None)
  {
    return Vect(0, 0, 0);
  }

  // Type cast to get the new player input
  LumDefPlayerInput = LumDefPlayerInput(PlayerOwner.PlayerInput);

  // Ensure that the player input is valid
  if (LumDefPlayerInput == None)
  {
    return Vect(0, 0, 0);
  }

  // We stored the mouse position as an IntPoint, but it's needed as a Vector2D
  MousePosition.X = LumDefPlayerInput.MousePosition.X;
  MousePosition.Y = LumDefPlayerInput.MousePosition.Y;
  // Deproject the mouse position and store it in the cached vectors
  Canvas.DeProject(MousePosition, MouseWorldOrigin, MouseWorldDirection);

  // Perform a trace to get the actual mouse world location.
  Trace(HitLocation, HitNormal, MouseWorldOrigin + MouseWorldDirection * 65536.f, MouseWorldOrigin , true,,, TRACEFLAG_Bullet);
  return HitLocation;
}

//Retorna as cordenadas 2D do mouse
function vector2D GetMouseCoordinates()
{
        local Vector2D mousePos;
	local LumDefPlayerInput LocalPlayerInput;

	//Asseguramos que temos um PlayerController valido
	if (PlayerOwner != None)
	{
		//Type cast para LumDefPlayerInput
		LocalPlayerInput = LumDefPlayerInput(PlayerOwner.PlayerInput);
		mousePos.X = LocalPlayerInput.MousePosition.X;
		mousePos.Y = LocalPlayerInput.MousePosition.Y;
	}

        return mousePos;
}

//Retorna o tamanho da tela
function vector2D getScreenSize()
{
	local Vector2D screenDimensions;
	ScreenDimensions.X = Canvas.SizeX;
	ScreenDimensions.Y = Canvas.SizeY;

	return screenDimensions;
}

DefaultProperties
{
        //Definimos por padrao usar o cursor em ScaleForm
        UsingScaleForm=True;
        //Defimos por padrao a cor do cursor
        CursorColor=(R=255, G=255, B=255, A=255)
        //Definimos por padrao a textura do cursor
        CursorTexture=Texture2D'LumDefContent.Textures.cursor_png'
}