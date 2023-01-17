// SPDX-License-Identifier: GPL-3.0

//Pragma define las versiones donde funcionara nuestro codigo
pragma solidity >=0.7.0 <0.9.0;


contract CrowdFunding {
    //Creamos una variable que solo puede tener 2 valores
    enum fundraising_State {Opened,Closed}

//Usaeremos el Struc para poder guardar todas estas variables 
//ya no necesitan de un valor inicial de public , 
//pues luego declararemos projec public = Project

    struct Project {
        string  id;
        string  name;
        string  description;
        address payable  author;
        //Se le cambio el tipo de variable
        fundraising_State  state ;
        uint256  funds;
        uint256  fundraisingGoal;
    }

    //declaramos la variable project , que es un tipo Project la cual tiene las variables internas
    Project public project;

    //Anteriormente definimos las variables que se usaran , entonces constructor las DEFINE
    //al DEFINIRLAS les agregamos valores permanentes , cosas como DUEÑO
    constructor(
        string memory _id,
        string memory _name,
        string memory _description,
        //"DEFINIMOS" permanentemente el valor que se busca alcanzar, sera de 1 ether.
        uint256 _fundraisingGoal
    ) {
        project=Project(
        // a cada una de las variables se les concatena el "porject."  pues ahora tiene un valor
        //dentro de un casillero
        _id,
        _name,
        _description,
        payable(msg.sender),
        //Cambiamos el tipo de esta variable
        fundraising_State.Opened,
        0,
        _fundraisingGoal);
    }

//QUE SON LOS EVENTOS   permiter conectar lo que esta dentro de la Blockchain sin estar en ellas , no
//queremos gastar de mas .Ejem :para mostrar anuncios , indicaciones , etc

    //
    event ProjectFunded (
        string projectId,
        uint value
    );

    event ProjectStateChanged (
        string id,
        //Se le cambia al nuevo enum tipe
        fundraising_State state
    );

    //para pagar al author original del proyecto , "modfier isnotAuthor"
    function fundProject() public payable isNotAuthor {
        require(project.state != fundraising_State.Closed , "The project cant not recibe founds");
        require(msg.value>0, "Fund value must be greater than 0");
        project.author.transfer(msg.value);
        project.funds += msg.value;
        //aplicamos el evento ,el ID y la cantidad de valor 
        emit ProjectFunded(project.id,msg.value);
    }

    //Para abrir y cerrar el CrownFunding
    //Se le cambia el tipo del parametro inial a funraising_Sate
    function changeProjectState(  fundraising_State newState) public isAuthor {
        require(project.state != newState ,"New state need be diferent");
        project.state = newState;
        //aplicamos el evento , el ID y si esta abierto o cerrado
        emit ProjectStateChanged(project.id , newState);
    }

    //Creamos 2 modifier
    modifier isAuthor() {
        require(project.author == msg.sender, "You need to be the project author");
        _;
    }

    modifier isNotAuthor() {
        require(
            project.author != msg.sender,
            "As author you can not fund your own project"
        );
        _;
    }
    
}