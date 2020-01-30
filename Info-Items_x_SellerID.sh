#
#!/bin/bash
#
#######################################################################################################
  #####    SCRIPT PARA OBTENER ID, Title, Category_ID y Categorry_Name, a partir de Seller_ID   #####
#######################################################################################################
###################################################################################################
#####                      #####                          #####                  ##################
#####  Creado: 28/01/2020  #####   Por: Nicolas Cucatto   #####   Version: 1.0   ##################
#####                      #####                          #####                  ##################
#######################################################################################################
  ##########    Registro de Cambios    ##############################################################
#######################################################################################################
###  Fecha:                #####   Comentarios:                                            ########
###  Version:              #####                                                           ########  
###################################################################################################
#######################################################################################################



##################################################################
  #####  --- Inicio Definicion Funcion "Carga_Manual" ---  #####
##################################################################

function Carga_Manual
   {
SellerID=1
	while [ $SellerID != 0 ]
	 do
            read -p "Ingrese Seller_ID o 0 para finalizar la carga y ejecutar: " SellerID
	      if [ $SellerID != 0 ]
                 then
                 echo $SellerID >> /tmp/listado_sellerid.txt
	      fi
         done
    }

###############################################################
  #####  --- Fin Definicion Funcion "Carga_Manual" ---  #####
###############################################################



##################################################################
  #####  --- Inicio Definicion Funcion "Get_Info_Api" ---  #####
##################################################################

function  Get_Info_Api
    {

echo -e "\nProcesando, espere por favor..."             ## Prompt avisando ejecuccion del script
input="/tmp/listado_sellerid.txt"                       ## Carga de los IDs ingresados a variable "input"
   while IFS= read -r line                              ## Loop por ID
      do
 
        curl  -s  https://api.mercadolibre.com/sites/MLA/search?seller_id=$line |  jq -c  '.results[] | .category_id' >> /tmp/dummy.txt
          sed -i 's/"//g' /tmp/dummy.txt 		## Retiro las comillas del archivo dummy.txt


## obtener nombre categoria usando Category_ID del archivo de dummy.txt
          
	    for registro in `cat /tmp/dummy.txt`
               do
	       	curl -s https://api.mercadolibre.com/categories/$registro | jq -c '.name' >> /tmp/categorias.txt
               done


## obtener ID, Title y CategoryID del Item usando el Seller_ID

             curl  -s  https://api.mercadolibre.com/sites/MLA/search?seller_id=$line |  jq -c  '.results[] | {id,title,category_id}' >> /tmp/data.txt
		sed -i 's/^/"category_name":/' /tmp/categorias.txt 	## Agrego category_name para respetar formato en output final
		sed -i 's/}//g' /tmp/data.txt				## Sacamos la Llave que cierra al final de data


	paste -d ',' /tmp/data.txt /tmp/categorias.txt >> /tmp/data_final.txt    ## Join con paste de contenido de ambos archivos en archivo aux data_final.txt

	sed -i 's/$/}/g' /tmp/data_final.txt			                 ## Volvemos a poner la Llave final (})

	mv /tmp/data_final.txt /tmp/Resultado_$line.txt                            ## Renonmbrado de archivo aux data_final.txt a "Resultado_SellerID.txt"


## Limpieza de archivos auxiliares para siguiente loop

rm -f /tmp/dummy.txt /tmp/data.txt /tmp/categorias.txt /tmp/data_final.txt


          done < "$input"            ##  Fin While


## Limpieza de archivo auxiliar que contiene Sellers_ID ingresados y prompt mensaje fin script

rm -f /tmp/listado_sellerid.txt

echo -e "\nFin del script. Los resultados estan disponibles en /tmp/Resultados_"sellerID".txt"

    }
 
###############################################################
  #####  --- Fin Definicion Funcion "Get_Info_Api" ---  #####
###############################################################


#################################################
  #####     INICIO EJECUCION SCRIPT      ######
#################################################

 echo -e  "\nSeleccione una opcion: \n  1- Carga manual de uno o multiples SellerID  \n  2- Tomar SellerID del arhivo 'listado_sellerid.txt' \n  3- Salir" 
 read Opcion

  case $Opcion in 
 
      1)
         Carga_Manual
         Get_Info_Api
         ;; 

      2)
         Get_Info_Api
         ;; 

      3)
	 echo -e "\nHasta luego."
	 exit
         ;;

  esac

##############################################
  #####     FIN EJECUCION SCRIPT      ######
##############################################