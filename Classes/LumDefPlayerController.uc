class LumDefPlayerController extends PlayerController;

/*Sobrescrevo a funcao UpdateRotation da classe mae apenas para
 deixar a rotacao da camera estatica enquanto se move o mouse*/
function UpdateRotation(float DeltaTime);

DefaultProperties
{
        //Definimous nossa propria classe PlayerInput
        InputClass=class'LumDefGame.LumDefPlayerInput'
}