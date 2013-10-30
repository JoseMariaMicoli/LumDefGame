class LumDefHUD extends UDKHUD;

//Armazena a textura que representa o cursor na tela
var const Texture2D CursorTexture;
//Armazena a cor do cursor
var const Color CursorColor;
//Estamos usando ScaleForm?
var bool UsingScaleForm;
//variavel pronta para cast de LumDefCursorGFx
var LumDefCursorGFx LumDefCursorGFx;

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
        //local instances of our camera and controller ready to cast
	local LumDefCamera PlayerCam;
        local LumDefPlayerController LumDefPlayerController;

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



		LumDefPlayerController = LumDefPlayerController(PlayerOwner);
		LumDefPlayerController.PlayerMouse = GetMouseCoordinates();

		//from 2d mouse co-ordinates
		Canvas.DeProject(LumDefPlayerController.Playermouse, LumDefPlayerController.MousePositionWorldLocation, LumDefPlayerController.MousePositionWorldNormal);
		
		//get a type casted reference to custom camera
		Playercam = LumDefCamera(LumDefPlayerController.PlayerCamera);

		//calculate the various of the mouse curson position.

		//Set the ray direction as the mouseWorldnormal
		LumDefPlayerController.rayDir = LumDefPlayerController.MousePositionWorldNormal;

		//Start the trace at the player camera (isometric) + 100 unit z and a little offset in front of the camera (direction *10)
		LumDefPlayerController.StartTrace = (PlayerCam.ViewTarget.POV.Location + Vect(0,0,100)) + LumDefPlayerController.raydir * 10;

		//End this ray at start + the direction multiplied by given distance (5000 unit is far enough generally)
		LumDefPlayerController.endtrace = LumDefPlayerController.StartTrace + LumDefPlayerController.Raydir * 5000;
		
		//Trace MouseHitWorldLocation each frame to world location (here you can get from the trace the actors that are hit by the trace, for the sake of this
        //simple tutorial, we do noting with the result, but if you would filter clicks only on terrain, or if the player clicks on an npc, you would want to inspect
        //the object hit in the StartFire function
		LumDefPlayerController.TraceActor = trace(LumDefPlayerController.MouseHitWorldLocation, LumDefPlayerController.MouseHitWorldNormal, 
			LumDefPlayerController.EndTrace, LumDefPlayerController.StartTrace, true);

		//Calculate the pawn eye location for debug ray and for checking obstacles on click.
		LumDefPlayerController.PawnEyeLocation = Pawn(PlayerOwner.ViewTarget).Location +
			Pawn(PlayerOwner.ViewTarget).EyeHeight * Vect(0,0,1);

		super.PostRender();
}

function vector2D GetMouseCoordinates()
{
        local Vector2D mousePos;
		local string stringMessage;
		local LumDefPlayerInput LocalPlayerInput;

		// Ensure that we have a valid PlayerOwner and CursorTexture
		if (PlayerOwner != None)// && CursorTexture != None) 
		{
		// Cast to get the MouseInterfacePlayerInput
			LocalPlayerInput = LumDefPlayerInput(PlayerOwner.PlayerInput);
			mousePos.X = LocalPlayerInput.MousePosition.X;
			mousePos.Y = LocalPlayerInput.MousePosition.Y;
                        
			stringMessage = mousePos.X@mousePos.Y;
		}

		Canvas.DrawColor = Makecolor(255,183,255,255);
		Canvas.SetPos(250,40);
		Canvas.DrawText(stringMessage, false,,,Textrenderinfo);

        return mousePos;
}

//return screen size
function vector2D getScreenSize()
{
		local Vector2D screenDimensions;		
		ScreenDimensions.X = Canvas.SizeX;
		ScreenDimensions.Y = Canvas.SizeY;

		return screenDimensions;
}

DefaultProperties
{
        UsingScaleForm=True;
        //Defimos por padrao a cor do cursor
        CursorColor=(R=255, G=255, B=255, A=255)
        //Definimos por padrao a textura do cursor
        CursorTexture=Texture2D'LumDefContent.Textures.cursor_png'
}