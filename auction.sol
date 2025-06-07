// SPDX-License-Identifier: GPL-3.0

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

    constructor(address _auction, uint256 duration) {
        owner = _auction;
        endAuction = block.timestamp + duration;
    }

    receive() external payable {}

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
        if (endAuction == 0) {
            auctionClosed = true;
            end = "Subastado cerrado";
            emit finDeSubasta(end);
        }   
        require(!auctionClosed, "subasta cerrada");
        require((block.timestamp < endAuction), "Tiempo agotado");
        require(msg.value >= (higherOffer + higherOffer * 5 / 100), ("la oferta debe ser mayor"));
        (bool result, ) = msg.sender.call{value:msg.value}("");
        require(result);
        if (offers[msg.sender] != 0){
            (bool result2, ) = msg.sender.call{value:offers[msg.sender]}("");
            require(result2);
        }
        offers[msg.sender] = msg.value; 
        higherOffer = msg.value;
        addressHigherOffer = msg.sender;
        biddersHigherOffer.push(msg.sender);
        emit altaOferta(addressHigherOffer, higherOffer);
        if ((endAuction - block.timestamp) <= 600) {
            endAuction += 600;
        }
    }

    /* Función returnBid, permite devolver las ofertas que no ganaron:*/
    function returnBid() onlyOwner external payable{
        require((auctionClosed = false), "aun activa" );
        for(uint i = 0 ; i < biddersHigherOffer.length ; ++i) {
            if (biddersHigherOffer[i] != addressHigherOffer) {
                bidRestComision = (offers[biddersHigherOffer[i]]) - (offers[biddersHigherOffer[i]]) * 2 /100;
                (bool result3, ) = biddersHigherOffer[i].call{value:bidRestComision}("");
                require(result3);
            }

    

        }
    }
}
/* 
******Función bid, permite hacer ofertas y valida:
- que la subasta esta activa.
- que no se haya agotado el tiempo.
- que la oferta sea mayor que la ultima por un 5%.
- que el call a receive se complete.
- el if comprueba que el oferente ya había ofertado y logra la mayor oferta se le devuelve la anterior.
esto asegura que cada oferente tiene una sola oferta y agiliza la devolución al finalizar la subasta.
- se todo es válido guarda la address y el mayor valor de esa address en un mapping 'offers'.
- si todo es válido registra en una variable la mayor oferta 'higherOffer'.
- guarda las address de los oferentes en un array 'bidders' para su posterior devolución cuando finalice.
- Emite un evento cuando hay una oferta mayor con la direccion y el monto.
- Comprueba si la oferta esta en los últimos 10 min (600seg), si es si agrega otros 10 min. 
 
******Función returnBid, permite devolver las ofertas que no ganaron:
- valida que solo el dueño de la subasta pueda llamar la fucnión con el modificador onlyOwner.
- valida que la subasta ya este acabada.
- devuelve las ofertas perdedoras a sus dueños menos el 2% de comisión.
*/