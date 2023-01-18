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

//Una nueva estruct para poder vincularlos en un mapping
    struct Contribution {
        address contributor;
        uint value;
    }

    //declaramos la variable project , que es un tipo Project la cual tiene las variables internas
    //Ahora queremos que nuestra funcion tenga variso proyectos, cambiamos su nombre
    Project[] public projects;

    //Queremos colocar de "llave" un string , que se asocie a un contribuir(wallet,valor) 
    mapping (string => Contribution[])public contributions;

    //Anteriormente definimos las variables que se usaran , entonces constructor las DEFINE
    //al DEFINIRLAS les agregamos valores permanentes , cosas como DUEÑO

//Creamos un nuevo evento ProjectCreated , este ira dentro de la funcion crear proyectos
//nos informara el Indece,nombre,descripcion y al MetadeFondos

    event ProjectCreated(
        string projectId,
        string name,
        string description,
        uint fundraisingGoal

    );

    //Creamos 2 modifier 
    //Ahora tenemos que cambiar el lugar de los modifiers y asignarles un valor uint , esto para 
    //que pueda buscar el index
    modifier isAuthor(uint projectIndex) {
        //Le agregamos un buscador que cumple la funcion de Index
        require(projects[projectIndex].author == msg.sender, "You need to be the project author");
        _;
    }

    modifier isNotAuthor(uint projectIndex ) {
        //Le agregamos rl buscador que cumple la funcion de Index
        require(
            projects[projectIndex].author != msg.sender,
            "As author you can not fund your own project"
        );
        _;
    }

// ALERTA RECORDAR , eliminaremos el anterior constructor debido a que hora seran varios Proyectos
//En su lugar crearemos una funcion que se encarga de crear proyectos
//Estos seran indexados para ubicarlos
function createProject  (string calldata id, string calldata name, string calldata description ,uint fundraisingGoal ) public {
    require(fundraisingGoal > 0, "The goel cant be 0");
    //La creacion del proyecto con los mismos parametros
    Project memory project = Project(
        id,
        name,
        description,
        payable(msg.sender),
        fundraising_State.Opened,
        0,
        fundraisingGoal
    );
    projects.push(project); 
    emit ProjectCreated (id,name,description,fundraisingGoal);
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
    //Modificamos fundProject , para que pueda buscar el proyecto a fondear y luego la cantidad
    function fundProject(uint projectIndex ) public payable isNotAuthor(projectIndex) 
     {
        //AVISO como tal no se creo la variable "project" , por eso ahora creamos un variable local
        // es variable local tomara o imitara el valor de el casillero "projects" 
        // siguiendo la guia de "projectIndex"
        Project memory project = projects[projectIndex];
        require(project.state != fundraising_State.Closed , "The project cant not recibe founds");
        require(msg.value>0, "Fund value must be greater than 0");
        project.author.transfer(msg.value);
        project.funds += msg.value;
        //La llave del Mapping es el " ID " y el valor asignado son los datos del " Contribution "
        contributions[project.id].push(Contribution(msg.sender , msg.value));
        //aplicamos el evento ,el ID y la cantidad de valor 
        emit ProjectFunded(project.id,msg.value);
    }

    //Para abrir y cerrar el CrownFunding
    //Se le cambia el tipo del parametro inial a funraising_Sate
    //Se le agrega el parametro projectIndex
    function changeProjectState( fundraising_State newState , uint projectIndex) public isAuthor(projectIndex) {
        //Se le asigna una variable local/temporal , que simule  los valores de un casillero
        // segun el INDEX que este tenga
        Project memory project = projects[projectIndex];
        require(project.state != newState ,"New state need be diferent");
        project.state = newState;
        //aplicamos el evento , el ID y si esta abierto o cerrado
        emit ProjectStateChanged(project.id , newState);
    }
   
}