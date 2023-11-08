#! /bin/zsh

# GESTOR DE PROYECTOS DJANGO
readonly autor="GUScode"

# ----------------------------------------------------------- Colores para texto
blanco="\033[0m\e[0m"
green="\e[0;32m\033[1m"
green_fondo="\e[0;30;42m\033[1m"
red="\e[0;31m\033[1m"
blue="\e[0;34m\033[1m"
yellow="\e[0;33m\033[1m"
turquoise="\e[0;36m\033[1m"
purple="\e[0;35m\033[1m"
grey="\e[0;30m\033[1m"



# ---------------------------------------------------------- html plantilla base
html_base=$(cat << 'EOF'
<!DOCTYPE html>
<html lang="es">
    <head>
        {% load static %}
        <meta charset="utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=1">
        <title>{% block title %}{% endblock %}</title>
        <link href="{% static 'App_Core/css/styles.css' %}" rel="stylesheet">
    </head>

    <body>
        {% content block %}
        {% endblock %}
    </body>

    <footer>
    </footer>
</html>
EOF
)



# ----------------------------------------------------------- html plantilla app
html_plantilla=$(cat << 'EOF'
{% extends "base.html" %}

{% block title %} titulo {% endblock %}

{% load static %}

{% block content %}
    <main>
        contenido
    </main>
{% endblock %}
EOF
)



# ---------------------------------------------------------------- plantilla css
css_styles=$(cat << 'EOF'
/* ------------------------------------------------------ Nombre del Proyecto */
/* Descripción leve del proyecto */

:root {
  --fuente-family: 'Roboto', sans-serif;          /* fuentes */
  --fuente-color: hsla(0, 0%, 19%, 1);            /* color de fuentes */
  --fondo-body: hsla(0, 0%, 86%, 1);              /* background body */
  --fondo-sesion: hsla(0, 0%, 100%, 1);           /* backgrund secciones */
  --boton-color: hsla(212, 76%, 55%, 1);          /* color botones */
  --boton-color-active: hsla(212, 76%, 36%, 1);   /* color botón activo */
  --centrado: center;                             /* centrado de contenedores */
}

/* ---------------------------------------------------------- Estilos de Base */
* {
  box-sizing: border-box;
  margin: 0;
  background-color: var(--fondo-body);
  color: var(--fuente-color);
  font-family: var(--fuente-family);
}

/* ----------------------------------------- Estilos Sección <nombre sección> */
EOF
)



# ------------------------------------------------------------- urls de App_Core
urls_python=$(cat << 'EOF'
""" ------------------------------------------------------- App_Core => urls """

from django.urls import path
from App_Core import views

urlpatterns = [
    path('', views.portada, name='PORTADA'),           # ejemplo
]
EOF
)



# --------------------------------------------------------------------- tareas()
# Muestra lista de tareas o instrucciones que se pueden ejecutar
# parámetro: No requerido

function tareas(){
    echo -e "\n${turquoise}󰌠 GUScode-Django ${blanco}| Gestor Proyectos Django"
    echo "${yellow} "
    echo "comando         param-1      param-2    param-3$   tarea${blanco}"
    echo "dj_nuevo        <proyecto>                         => Crear Entorno y Nuevo proyecto"
    echo "dj_run          <proyecto>                         => Correr Servidor"
    echo "dj_app          <proyecto>   <app>                 => Crear Nueva Aplicación" 
    echo "dj_migraciones  <proyecto>                         => Comprobar Cambios (makemigrations)"
    echo "dj_migrar       <proyecto>                         => Hacer Migraciones"
    echo "dj_sql          <proyecto>   <app>      <n° mig>   => Generar SQL de tablas"
    echo "dj_usuario      <proyecto>                         => Crear super usuario"
    echo "dj_plantilla    <proyecto>   <app>      <archivo>  => Crear plantilla html en app"
    echo ""
    echo "autor: ${autor}"
}



# ---------------------------------------------------------------- new-project()
# Crea el entorno necesario para el proyecto
#   - entorno virtual venv
#   - Intalación de Django
# Inicio del Proyecto
# Creación de la App_Core como applicación principal
#   - static: App_Core/css img
#   - templates: App_Core
# parámetro: Nombre del Proyecto

function new-project(){
    ruta_root=$(pwd)
    sudo pacman -S --noconfirm python-virtualenv
    python -m virtualenv venv
    entorno
    pip install Django
    django-admin startproject Proyecto_$1
    echo "Creado el entorno => Proyecto_$1"
    entorno
    echo "Creando App Core ..."
    dj_app $1 Core
    eval "cd $(pwd)/Proyecto_$1"
    mkdir media
    eval "cd ${ruta_root}/Proyecto_$1/App_Core"
    touch urls.py
    echo "${urls_python}" > urls.py
    mkdir static templates
    eval "cd $(pwd)/static"
    mkdir App_Core
    eval "cd $(pwd)/App_Core"
    mkdir css img
    eval "cd $(pwd)/css"
    touch styles.css
    echo "${css_styles}" > styles.css
    eval "cd ${ruta_root}/Proyecto_$1/App_Core/templates"
    mkdir App_Core
    eval "cd $(pwd)/App_Core"
    touch base.html
    echo "${html_base}" > base.html
    eval "cd ${ruta_root}"
    echo "${grey}------------------------------${blanco}Nuevo Entorno:${green} Proyecto_$1${blanco}"
    echo "Se han creados las Carpetas: static - templates"
}



# -------------------------------------------------------------------- new-app()
# Crea nuevas aplicaciones y la debida carpeta de la app en templates
# parámetro 1: Nombre del proyecto
# parámetro 2: Nombre de la nueva app

function new-app(){
    if [ $# -eq 0 ]; then
        echo "${red}Error: no se ha especificado un nombre de Proyecto y App${blanco}"
        return 1
    fi
    ruta_root=$(pwd)
    eval "cd $(pwd)/Proyecto_$1"
    python manage.py startapp App_$2
    eval "cd ${ruta_root}/Proyecto_$1/App_Core/templates"
    mkdir App_$2
    echo "${grey}------------------------------${blanco}Nueva Aplicación creada:${green} App_$2${blanco}"
    echo "${turquoise}TODO => Registro de la app en el proyecto ${yellow}󰭺"
    eval "cd ${ruta_root}"
}



# ------------------------------------------------------------------------ run()
# Corre el servidor en localhost
# parámetro : Nombre del proyecto

function run(){
    if [ $# -eq 0 ]; then
        echo "${red}Error: no se ha especificado un nombre de Proyecto${blanco}"
        return 1
    fi
    ruta_root=$(pwd)
    echo -e "${grey}------------------------------${green} Corriendo Servidor 󱓞 ${blanco}"
    eval "cd $(pwd)/Proyecto_$1"
    python manage.py runserver
    eval "cd ${ruta_root}"
}



# ---------------------------------------------------------------- migraciones()
# Comprueba cambios ne los modelos
# parámetro: Nombre del proyecto

function migraciones(){
    if [ $# -eq 0 ]; then
        echo "${red}Error: no se ha especificado un nombre de Proyecto${blanco}"
        return 1
    fi
    ruta_root=$(pwd)
    echo -e "${grey}------------------------------${green} Comprobando Cambios 󱤟 ${blanco}"
    eval "cd $(pwd)/Proyecto_$1"
    python manage.py makemigrations
    echo "${turquoise}TODO => Tomar nota del número de migraciones ${yellow}󰭺"
    eval "cd ${ruta_root}"
}



# -------------------------------------------------------------------- migrate()
# Ejecuta las migraciones pendientes
# parámetro: Nombre del Proyecto

function migrate(){
    if [ $# -eq 0 ]; then
        echo "${red}Error: no se ha especificado un nombre de Proyecto${blanco}"
        return 1
    fi
    ruta_root=$(pwd)
    echo -e "${grey}------------------------------${green} Realizando Migraciones 󰪩 ${blanco}"
    eval "cd $(pwd)/Proyecto_$1"
    python manage.py migrate
    eval "cd ${ruta_root}"
}



# ------------------------------------------------------------------------ sql()
# Genera el código sql para las tablas
# parámetro 1: Nombre del Proyecto
# parámetro 2: Nombre de la aplicación origen de los modelos
# parámetro 3: Número de las migraciones

function sql(){
    if [ $# -eq 0 ]; then
        echo "${red}Error: no se ha especificado un nombre de Proyecto, App o n° migración${blanco}"
        return 1
    fi
    ruta_root=$(pwd)
    echo -e "${grey}------------------------------${green} Código SQL Generado  ${blanco}"
    eval "cd $(pwd)/Proyecto_$1"
    python manage.py sqlmigrate App_$2 $3
    eval "cd ${ruta_root}"
}



# ----------------------------------------------------------------------- user()
# Crea super usuario con permisos de Administrador
# parámetro: Nombre del proyecto

function user(){
    if [ $# -eq 0 ]; then
        echo "${red}Error: no se ha especificado un nombre de Proyecto${blanco}"
        return 1
    fi
    ruta_root=$(pwd)
    echo -e "${grey}------------------------------${turquoise} Creado Super-Usuario  ${blanco}"
    eval "cd $(pwd)/Proyecto_$1"
    python manage.py createsuperuser
    eval "cd ${ruta_root}"
}



# ------------------------------------------------------------- html-plantilla()
# Crea plantillas básicas html para aplicaciones
# parámetro 1: Nombre del Proyecto
# parámetro 2: Nombre de la aplicación
# parámetro 3: Nombre del archivo .html
function html-plantilla(){
    if [ $# -eq 0 ]; then
        echo "${red}Error: no se ha especificado un nombre de Proyecto${blanco}"
        return 1
    fi
    ruta_root=$(pwd)
    echo -e "${grey}------------------------------${turquoise} Plantilla html $3  ${blanco}"
    eval "cd $(pwd)/Proyecto_$1/App_Core/templates/App_$2"
    touch $3
    echo "${html_plantilla}" > $3
    eval "cd ${ruta_root}"
}

