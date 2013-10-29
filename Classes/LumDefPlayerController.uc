class LumDefPlayerController extends PlayerController;

var bool bPressingMouseLeftButton;
var bool bPressingMouseRightButton;

event PlayerTick(float DeltaTime)
{
        if (bPressingMouseLeftButton)
        {

        }
}

/*Sobrescrevo a funcao UpdateRotation da classe mae apenas para
 deixar a rotacao da camera estatica enquanto se move o mouse*/
function UpdateRotation(float DeltaTime);

exec function PressionarBotaoEsquerdo()
{
    bPressingMouseLeftButton = true;
}

exec function SoltarBotaoEsquerdo()
{
    bPressingMouseLeftButton = false;
}

exec function PressionarBotaoDireito()
{
    bPressingMouseRightButton = true;
}

exec function SoltarBotaoDireito()
{
    bPressingMouseRightButton = false;
}

DefaultProperties
{
        CameraClass=class'LumDefGame.LumDefCamera'
        //Definimous nossa propria classe PlayerInput
        InputClass=class'LumDefGame.LumDefPlayerInput'
        
        bPressingMouseLeftButton = false;
        bPressingMouseRightButton = false;
}