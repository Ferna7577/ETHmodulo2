# ETHmodulo2
Documentación Trabajo Práctico módulo 2 ETH Kipu
Versión 2.1
El código fuente se subió como auction.sol, el código esta comentado en su totalidad:
+La subasta es por tiempo definido en el deploy por el constructor del contrato que ejecuta el dueño del mismo.
+Al finalizar el tiempo se dispara un evento.
+Es por la oferta más grande, si un oferente hace dos ofertas, la mas baja se le devuelve apenas hace la segunda,
de esta manera simplifica la devolución del las ofertas perdedoras al final de la subasta.
+Si una oferta ingresa en los últimos 10 min de la subasta, se agregan 10 min más al tiempo de finalización.
+En el proceso de ofertas se puede consultar la oferta más grande y de que dirección proviene.
+Cada vez que se valida una oferta mayor se dispara un evento.
+Una vez finalizada la subasta en dueño de la subasta es el único con permisos para devolver los importes depósitados
perdedores que se ejecutan con la función "returnBid" descontandole un 2% a cada devolución en concepto de 
comisión.
+Todas las validaciones (requiere) tienen unas lineas descriptivas por si fallan. 


++++Descripción y funcionalidad de las funciones:
Función bid, permite hacer ofertas y valida:
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

Función returnBid, permite devolver las ofertas que no ganaron:
- valida que solo el dueño de la subasta pueda llamar la fucnión con el modificador onlyOwner.
- valida que la subasta ya este acabada.
- devuelve las ofertas perdedoras a sus dueños menos el 2% de comisión.

