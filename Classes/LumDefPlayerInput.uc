class LumDefPlayerInput extends PlayerInput;

/*Esta variavel armazena a posiçao 2D do cursor e damos escopo PrivateWrite para garantir
 que todas as classes possam leer dados mais apenas LumDefPlayerInput possa escrever*/
var PrivateWrite IntPoint MousePosition;

//Sobrescrevemos o evento PlayerInput da classe mae onde iremos pegar as cordenas 2D do cursor
event PlayerInput(float DeltaTime)
{
        //Asseguramos que temous um HUD valido
        if (myHUD != None)
        {
                //Adicionamos aMouseX a MousePosition e usamos Clamp para ajustalo com o tamanho da tela
                MousePosition.X = Clamp(MousePosition.X + aMouseX, 0, myHUD.SizeX);
                //Substraimos aMouseY a MousePosition e usamos Clamp para ajustalo com o tamanho da tela
                MousePosition.Y = Clamp(MousePosition.Y - aMouseY, 0, myHUD.SizeY);
        }
        
        //Executamos o evento PlayerInput da classe mae
        Super.PlayerInput(DeltaTime);
}

DefaultProperties
{

}