// Class definition, note that: DLLBind(SaveSystem);
class SaveSystemString extends Object DLLBind(SaveSystem);

// The max number of characters in one string
var int MAX_STRING_LENGHT;

// We have to define our structures here too //
// Declaring our character properties
struct SCharacterProperties
{
    var int iGoldHeld;
    var int iHealth;
    var int iMana;
};

// This strucure will hold all our character substructures //
struct SCharacterData
{
    var SCharacterProperties Properties;
    var string PlayerName;
    var string PlayerClass;
};

// Here we declare the functions we want to retrieve from the dll //
// You can check the link I gave from epics, tocheck conversion types from c++ to UnrealScript
dllimport final function bool SaveCharacter(string SaveName, SCharacterData CharaterData);
dllimport final function bool LoadCharacter(string SaveName, out SCharacterData CharaterData);

dllimport final function TestCharacterData(SCharacterData Character);

// The new implementation of the save //
function bool SaveTheCharacter(string SaveName, SCharacterData CharacterData)
{
    // Saving the properties //
   return SaveCharacter(SaveName, CharacterData);
}

// And the new implementation of the load function //
function bool LoadTheCharacter(string SaveName, out SCharacterData CharacterData)
{
    // Preparing the strings lenghts //
    PrepareData(CharacterData);
    // Loading the properties //
    return LoadCharacter(SaveName, CharacterData);
}

function PrepareData(out SCharacterData CharacterData)
{
    // The unreal needs to allocate the memory for the strings
    // We have to pass the struct to the dll with the memory already allocated
    // So we define a max length to the strings
    // 15 should be enough to our case
    local int i;
    CharacterData.PlayerName = " ";
    CharacterData.PlayerClass = " ";

    for (i = 0; i < MAX_STRING_LENGHT-1; ++i)
    {
        CharacterData.PlayerName @= " ";
        CharacterData.PlayerClass @= " ";
    }
}

DefaultProperties
{
    MAX_STRING_LENGHT = 16;
}