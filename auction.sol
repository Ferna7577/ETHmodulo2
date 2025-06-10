// SPDX-License-Identifier: GPL-3.0
//Versión 2.1
pragma solidity >=0.8.2 <0.9.0;

contract auction {

    uint256 endAuction; //Tiempo de duración
    address owner; //Dueño del contrato
    mapping(address => uint) offers; //dirección--oferta de cada oferente
    bool auctionClosed; //indicador de finalización de subasta
    uint256 public higherOffer; // oferta ganadora
    address public addressHigherOffer; // dirección ganadora
    address[] biddersHigherOffer; //array de direcciones con los oferentes en las ofertas
    uint256 bidRestComision; //usada para calcular bid menos comisión
    string end; //usada para emitir evento de fin de subasta

    /*El constructor, ingresa al dueño de la subasta y la duración de la misma*/
    constructor(address _auction, uint256 duration) {
        owner = _auction;
        endAuction = block.timestamp + duration;
    }

    /*Evento que registra la dirección y monto de la oferta mayor*/
    event altaOferta(address indexed userAddress, uint256 userId);
    /*Evento de fin de subasta*/
    event finDeSubasta(string end);

    /*Modificador para restringir la devolución de las ofertas perdedoras por el dueño*/
    modifier onlyOwner() {
       require(msg.sender == owner, "Solo Subastador ejecuta");
       _;
    }


    /*Función bid, validación y ejecución de ofertas*/
    function bid() external payable {
        /*Si se terminó el tiempo de la subasta, cambia el estado del flag de subasta 
        abierta para cerrarla y emite un evento de Subasta cerrada*/
        if (endAuction == 0) {
            auctionClosed = true;
            end = "Subastado cerrado";
            emit finDeSubasta(end);
        }
        /*que la subasta esta activa*/   
        require(!auctionClosed, "subasta cerrada");
        
        /*que no se haya agotado el tiempo*/
        require((block.timestamp < endAuction), "Tiempo agotado");
        
        /*que la oferta sea mayor que la ultima por un 5%*/    
        require(msg.value >= (higherOffer + (higherOffer * 5 / 100)), ("la oferta debe ser mayor"));
        
        /* El siguiente 'if' comprueba si el oferente ya había ofertado y logra la mayor oferta 
         se le devuelve la oferta inferior. Esto asegura que cada oferente tiene una sola oferta
         y agiliza la devolución al finalizar la subasta.*/
        if (offers[msg.sender] != 0){
            (bool result2, ) = msg.sender.call{value:offers[msg.sender]}("");
            require(result2);
        }
        /* Agrega la oferta más alta de cada oferente en un mapping*/
        offers[msg.sender] = msg.value; 
        /* Agrega la oferta más alta actual*/
        higherOffer = msg.value;
        /* Agrega de quien es la oferta más alta actual*/
        addressHigherOffer = msg.sender;
        /* Crea una lista de los oferentes, esto sirve para saber si hay dos ofertas del mismo
        oferente y devolverle la más baja antes de ingresar la más alta*/
        biddersHigherOffer.push(msg.sender);
        /* emite el evento de que hay una oferta más alta*/
        emit altaOferta(addressHigherOffer, higherOffer);
        /* si ingresa una oferta 10 min antes de terminar, suma otros 10 min a la subasta*/
        if ((endAuction - block.timestamp) <= 600) {
            endAuction += 600;
        }
    }

    /* Función returnBid, permite devolver las ofertas que no ganaron:*/
    function returnBid() onlyOwner external payable{
        require((auctionClosed = false), "aun activa" );
        /*Pone la oferta más alta del mapping 'offers' en 0 para no devolver al ganador pero si a los perdedores*/
        offers[addressHigherOffer] = 0;
        /* Recorre el array 'biddersHigherOffer' donde extrae las direcciones de los oferentes y las usa,
        para sacar el valor de la oferta de esa dirección del mapping 'offers'.*/
        for(uint i = 0 ; i < biddersHigherOffer.length ; ++i) {
            /* Saca el valor de la dirección a devolver y le resta el 2%*/
            bidRestComision = (offers[biddersHigherOffer[i]]) - ((offers[biddersHigherOffer[i]]) * 2 /100);
            /* Devuelve el valor anterior a la dirección que esta recorriendo*/
            (bool result3, ) = biddersHigherOffer[i].call{value:bidRestComision}("");
            require(result3);
            }

    }
}
