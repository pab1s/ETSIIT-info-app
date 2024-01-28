# Práctica 3: Interacción Oral mediante DialogFlow

Durante esta práctica, nuestro objetivo fue desarrollar un agente conversacional capaz de interactuar con los usuarios de nuestra aplicación móvil. Este agente puede responder preguntas y mantener diálogos fluidos sobre diversos aspectos relacionados con la ETSIIT, como profesores, asignaturas, horarios, entre otros.

Dicho asistente se construyó utilizando la interfaz web de DialogFlow y se basa en la información proporcionada por un servidor web que almacena una base de datos. Más tarde, integramos este agente en la aplicación de Android en forma de un ChatBot, lo que permite a los usuarios mantener conversaciones por voz. De esta manera, ofrecemos a los usuarios una herramienta eficaz y sencilla para consultar información relacionada con la facultad.

## 1. Desarrollo del agente

La herramienta **DialogFlow** de **GoogleCloud** ofrece una forma sencilla y, hasta cierto punto, gratuita, de generar interfaces conversacionales naturales, haciendo uso de *Natural Language Processing*. A continuación, abordamos los puntos clave del desarrollo.

#### 1.1. Intenciones

Los flujos de diálogo se gestionan mediante ***intenciones*** o *intents*, que definen el tipo de respuestas que se deben ofrecer ante ciertas entradas del usuario, conocidas como frases de entrenamiento. Cada *intent* se encarga de un propósito distinto. Para nuestro agente, creamos las siguientes intenciones:

- **ProximaClase**: Esta intención identifica frases como "*¿Qué clase tengo después?*", "*¿Qué asignatura hay a continuación?*" o "*¿Cuál es mi próxima clase?*".

- **PreguntarDespacho**: Se activa ante preguntas como "*¿Dónde está el despacho de Pablo Mesejo?*", "*¿Dónde trabaja Daniel Sánchez?*" o "*¿Dónde puedo ir a tutoría con Marcelino?*".

- **HorarioAsignaturas**: Definido para entradas del estilo "*¿Cuándo tengo clases de Nuevos Paradigmas de Interacción?*", "*¿Cuál es el horario semanal de Modelos Matemáticos?*" o "*¿Qué días tengo Cálculo?*".

- **PreguntarProfesorAsignatura**: Responde ante entradas como "*¿Quién imparte Estructura de Computadores?*", "*¿Cuál es el profesor de Estadística?*" o "*¿Con quién tengo Visión por Computador?*".

- **Chiste**: Responde con un chiste aleatorio ante una petición del usuario, como "*Cuéntame un chiste*", "*Alégrame el día*" o "*Hazme reír*".

- Además, DialogFlow ofrece dos intents por defecto para manejar situaciones comunes: **Default Welcome Intent** (para responder a un saludo) y "**Default Fallback Intent**" (se activa en caso de reconocer una frase desconocida). Estos se han modificado añadiendo algunos detalles personalizados en las respuestas.

#### 1.2. Entidades

Algunos de los intents admiten *parámetros*, para los cuales utilizamos ***entidades***, que determinan el aspecto de estos parámetros y nos ayudan a identificarlos dentro de las frases. Utilizamos dos tipos de entidades:

- **sys.person**: Esta entidad es proporcionada por DialogFlow y contiene una amplia variedad de nombres y apellidos de personas. Optamos por usar esta entidad para identificar los nombres de los profesores en lugar de crear una propia, ya que contiene una mayor variedad de nombres y facilita el reconocimiento durante la conversación.

- **asignatura**: Incluimos una gran cantidad de nombres de asignaturas de la ETSIIT en esta entidad, junto con algunos sinónimos asociados (por ejemplo, incluimos "Técnicas de los Sistemas Inteligentes" junto con "TSI"). Esta entidad la definimos manualmente, ya que no existe una entidad por defecto que detecte nombres de asignaturas de este tipo.

A la hora de redactar las frases de entrenamiento, indicamos la parte de la frase que corresponde a una entidad. De esta forma, el sistema se entrena para detectar variables dentro de las frases. 

Los parámetros asociados a entidades pueden marcarse como obligatorios dentro de los intents, para obligar al usuario a que los indique en su mensaje. En nuestro caso, se permite no indicar el parámetro, lo cual permite formular preguntas sin indicar explícitamente los nombres de asignatura o profesores, derivándose estos del contexto actual de la conversación.

#### 1.3. Respuestas

Para ofrecer respuestas personalizadas, utilizamos parámetros y contexto para acceder a una base de datos y proporcionar información realista. DialogFlow permite conectarse a un servicio externo que proporcione respuestas adecuadas según los inputs detectados, mediante la funcionalidad llamada **fulfillment**. Debemos activar la opción **webhook call** en aquellos intents donde queremos usar esta funcionalidad. Cuando se detecta el intent tras un mensaje del usuario, se envía una petición POST a la URL indicada para que sea procesada. Esta petición incluye una serie de argumentos recopilados por el agente a lo largo del diálogo, que se utilizan en las consultas.

En nuestro caso, levantamos un servidor web remoto mediante Node.js, al cual se accede a través de una URL que utiliza el protocolo HTTPs para mayor seguridad. Esto nos llevó a utilizar la herramienta *ngrok*, que genera URLs con este protocolo.

Dentro del archivo de servidor de Node.js, definimos un endpoint */webhook* desde donde manejamos las respuestas para cada intent.

Aquí se presenta un extracto de código que maneja la respuesta para el intent *ProximaClase*:

```javascript
async function proximaclase(agent) {
        const url = 'http://localhost:3000/api/proximaclase';
        try {
            const data = await makeHttpRequest(url);
            const jsonData = JSON.parse(data);

            if (jsonData.asignatura) {
                const asignatura = jsonData.asignatura;
                const respuestas = [
                    `Tu próxima asignatura es ${asignatura.tipo_de_grupo} de ${asignatura.asignatura} (grupo ${asignatura.grupo}), el ${asignatura.dia_de_la_semana} de ${asignatura.hora_inicio} a ${asignatura.hora_fin}`,
                    `La siguiente clase que tienes es ${asignatura.tipo_de_grupo} de ${asignatura.asignatura} (grupo ${asignatura.grupo}), el ${asignatura.dia_de_la_semana} desde ${asignatura.hora_inicio} hasta ${asignatura.hora_fin}`,
                    `${asignatura.tipo_de_grupo} de ${asignatura.asignatura}, en el grupo ${asignatura.grupo}, que es el ${asignatura.dia_de_la_semana} de ${asignatura.hora_inicio} a ${asignatura.hora_fin}`
                ];

                agent.context.set({
                    name: 'asignatura_info',
                    lifespan: 3, 
                    parameters: {
                        nombreAsignatura: asignatura.asignatura,
                        profesorAsignatura: asignatura.profesor,
                        tipoGrupoAsignatura: asignatura.tipo_de_grupo
                    }
                });

                agent.add(respuestaAleatoria(respuestas));
            } else {
                agent.add('No se encontraron asignaturas para tu usuario.');
            }
        } catch (error) {
            console.error(error);
            agent.add('Hubo un error al obtener la información de asignatura');
        }
    }
```

Como se puede observar, se realiza una petición a un endpoint */api/proximaclase* que consulta cuál es la próxima clase para un usuario específico, teniendo en cuenta las asignaturas en las que está matriculado, los horarios y la distancia en días de la semana desde el momento actual hasta la próxima clase. La respuesta contiene detalles como el profesor, el tipo de grupo, la hora de inicio, la hora de fin, etc.

Esta información se utiliza para construir una variedad de respuestas entre las cuales se selecciona una de manera aleatoria. Esto garantiza que el agente ofrezca respuestas variadas en lugar de repetir lo mismo con las mismas palabras.

También se maneja el caso en que el alumno no esté matriculado en ninguna asignatura o si ocurre un error inesperado en la base de datos.

Además, se actualiza un contexto y se prolonga su duración durante tres interacciones más. De esta manera, el usuario puede preguntar por el profesor que imparte esa clase o incluso preguntar directamente dónde puede encontrar al profesor de esa asignatura. Esto se logra a través de los intents **PreguntarProfesorAsignatura** y **PreguntarDespacho**, respectivamente. A continuación, se proporcionan más detalles sobre el contexto.

#### 1.4. Contextos

En DialogFlow, se puede almacenar un contexto a través de variables que permiten una conversación más natural y versátil.

En nuestro caso, utilizamos un contexto llamado **asignatura_info** con los parámetros *nombreAsignatura*, *profesorAsignatura* y *tipoGrupoAsignatura*, que se actualiza después de algunas interacciones. El contexto tiene una duración predeterminada de tres interacciones después de su actualización.

Estos contextos se modifican estratégicamente para eliminar información innecesaria o que no tiene sentido en cierto punto de la conversación, y para identificar desde qué intent se actualizó el contexto y proporcionar respuestas adecuadas.

Por ejemplo, al activar el intent **PreguntarProfesorAsignatura**, puede haber tres situaciones:

1. Haber preguntado previamente por la próxima clase (intent ProximaClase) y ahora querer conocer al profesor de esa asignatura.

2. Haber preguntado por el horario semanal de una asignatura (intent HorarioAsignaturas) y ahora querer saber quiénes son los profesores que imparten esa asignatura.

3. Preguntar directamente por los profesores de una asignatura específica.

A continuación, se presenta un extracto de código de la función manejadora de **PreguntarProfesorAsignatura**:

```javascript
async function preguntarProfesorAsignatura(agent) {
        let nombreAsignatura = agent.parameters.asignatura;
        const contextoAsignatura = agent.context.get('asignatura_info');

        if (!nombreAsignatura && contextoAsignatura && contextoAsignatura.parameters.tipoGrupoAsignatura && contextoAsignatura.parameters.profesorAsignatura) {
            const tipoGrupoAsignatura = contextoAsignatura.parameters.tipoGrupoAsignatura;
            const nombreAsignatura = contextoAsignatura.parameters.nombreAsignatura;
            const profesorAsignatura = contextoAsignatura.parameters.profesorAsignatura;

            const respuestas = [
                `Tu profesor en ${tipoGrupoAsignatura} de ${nombreAsignatura} es ${profesorAsignatura}`,
                `${profesorAsignatura} te da ${tipoGrupoAsignatura} de ${nombreAsignatura}`,
                `Tienes ${tipoGrupoAsignatura} de ${nombreAsignatura} con ${profesorAsignatura}`
            ];

            agent.add(respuestaAleatoria(respuestas));

            agent.context.set({
                name: 'asignatura_info',
                lifespan: 3,
                parameters: {
                    nombreAsignatura: nombreAsignatura,
                    profesorAsignatura: profesorAsignatura,
                    tipoGrupoAsignatura: null
                }
            });
        } else {
            if (!nombreAsignatura && contextoAsignatura) {
                nombreAsignatura = contextoAsignatura.parameters.nombreAsignatura;
            }

            if (!nombreAsignatura) {
                agent.add('Por favor, dime el nombre de la asignatura.');
                return;
            }

            const url = `http://localhost:3000/api/profesores?asignatura=${encodeURIComponent(nombreAsignatura)}`;
            try {
                const data = await makeHttpRequest(url);
                const jsonData = JSON.parse(data);

                if (Object.keys(jsonData).length > 1) {
                    let nombresAsignaturas = Object.keys(jsonData);
                    let pregunta = `¿Te refieres a ${nombresAsignaturas.slice(0, -1).join(', ')} o ${nombresAsignaturas.slice(-1)}?`;
                    agent.add(pregunta);
                } else if (Object.keys(jsonData).length === 1) {
                    let asignaturaEncontrada = Object.keys(jsonData)[0];
                    let infoProfesores = jsonData[asignaturaEncontrada];

                    let profesoresMap = new Map();
                    infoProfesores.forEach(p => {
                        if (profesoresMap.has(p.profesor)) {
                            profesoresMap.get(p.profesor).add(p.tipo_de_grupo);
                        } else {
                            profesoresMap.set(p.profesor, new Set([p.tipo_de_grupo]));
                        }
                    });

                    let textoProfesores;
                    let profesoresArray = Array.from(profesoresMap.entries());
                    if (profesoresArray.length === 1) {
                        // Solo hay un profesor
                        let [profesor, tiposGrupo] = profesoresArray[0];
                        let tipos = Array.from(tiposGrupo);
                        let tiposTexto = tipos.join(' y ');
                        textoProfesores = `Tu profesor de la asignatura ${asignaturaEncontrada} es ${profesor} (grupo ${tiposTexto})`;
                    } else {
                        // Hay varios profesores
                        textoProfesores = `Tus profesores de la asignatura ${asignaturaEncontrada} son `;
                        textoProfesores += profesoresArray.map(([profesor, tiposGrupo], index) => {
                            let tipos = Array.from(tiposGrupo).join(' y ');
                            return `${index === profesoresArray.length - 1 ? 'y ' : ''}${profesor} (grupo ${tipos})`;
                        }).join('; ');
                    }

                    agent.add(textoProfesores);

                    agent.context.set({
                        name: 'asignatura_info',
                        lifespan: 3,
                        parameters: {
                            nombreAsignatura: asignaturaEncontrada,
                            profesorAsignatura: profesoresArray.map(([profesor]) => profesor),
                            tipoGruposAsignatura: profesoresArray.map(([, tipos]) => Array.from(tipos)).flat()
                        }
                    });
                } else {
                    let respuestasFormatos = [
                        'No te has matriculado en esta asignatura.',
                        'No tienes esta asignatura este cuatrimestre.',
                        'No estás en las listas de esta asignatura.',
                        'No estás cursando esta asignatura'
                    ]

                    agent.add(respuestaAleatoria(respuestasFormatos));
                }
            } catch (error) {
                console.error(error);
                agent.add('Hubo un error al obtener la información de los profesores');
            }
        }
    }
```

Como se puede observar, si no se ha proporcionado un nombre de asignatura en los parámetros, esto indica que el usuario está haciendo referencia a una asignatura que ya ha sido mencionada previamente en la conversación. En tal caso, analizamos el contexto.

Si en el contexto se encuentran presentes el profesor, la asignatura y el tipo de grupo, significa que previamente habíamos consultado sobre nuestra próxima clase. En este escenario, el agente simplemente proporciona una respuesta utilizando la información disponible en el contexto.

Por otro lado, si alguno de estos atributos no está presente en el contexto, esto indica que no se había preguntado recientemente por nuestra próxima clase. En este caso, la pregunta sobre el profesor de una asignatura no se refiere a una clase específica, sino a la asignatura en general. En este escenario, tomamos el nombre de la asignatura, que estará presente en el contexto o en el argumento proporcionado (dando prioridad a esta última opción), y accedemos al endpoint */api/profesores* para consultar qué profesores imparten esa asignatura, utilizando la información de la base de datos. Luego, proporcionamos una respuesta adaptada según si hay uno o varios profesores. Finalmente, actualizamos el contexto para incluir varios profesores y sus respectivos grupos, lo que permite su uso en el siguiente intent. La variación de la respuesta en los intents subsiguientes dependerá de si hay uno o varios profesores. A esto nos referimos con "actualización estratégica" del contexto.

Un detalle a destacar es que también manejamos la situación en la que el nombre de la asignatura proporcionada coincida con varias opciones. En este caso, permitimos al usuario especificar cuál de las opciones parcialmente coincidentes es la que le interesa. Por ejemplo, si se consulta por "Fundamentos" y el usuario está matriculado en "Fundamentos del Software" y "Fundamentos de Programación", se le dará la posibilidad de elegir entre estas opciones.

El usuario solo podrá consultar información de asignaturas en las que esté matriculado. Si no lo está, se mostrará un mensaje del tipo "No estás cursando esta asignatura".

Esto es solo un ejemplo del complejo flujo de interacción que se ha implementado, para otros detalles sobre el mismo y sobre las consultas realizadas mediante SQL en cada caso, consulte el archivo `serverDialogflow.js`.

## 2. Integración con la aplicación de Android

Para integrar el agente con nuestra aplicación de Android, hicimos uso de las librerías para Flutter, las cuales añadimos al archivo `pubspec.yaml`:

- `dialogflow_grpc`: Este paquete será necesario para establecer conexión con la API de DialogFlow y poder tener acceso a nuestro agente desde fuera de la interfaz web. Para configurar la conexión, hemos de utilizar una clave del proyecto en formato JSON que se encuentra en nuestra cuenta de Google Cloud.

- `flutter_tts`: Este paquete nos permite que los textos sean reproducidos por voz, para que las respuestas del agente se ofrezcan en formato de audio.

Creamos una interfaz clásica de ChatBot, en la cual podemos interactuar con el agente construido mediante texto o audio. Para la interacción mediante audio, consideramos suficiente la opción de que el usuario use el micrófono integrado en el teclado de cualquier teléfono Android, abriendo así la posibilidad de que también se interactúe por texto, lo cual puede ser útil si se quiere realizar una consulta en un ámbito que impida el uso de la voz (por ejemplo, en medio de una reunión o clase). La respuesta vendrá dada también en formato de texto y de audio, leído con la voz de una mujer y en español, como se muestra en la siguiente línea de código:

```dart
flutterTts?.setLanguage("es-ES");
```

También se podrían modificar otros parámetros como velocidad del discurso, gravedad de la voz, etc, pero nosotros hemos decidido dejar los valores por defecto.

Cuando abandonamos la interfaz del asistente, este se reinicia (se borran los mensajes y se limpia el contexto).

## 3. Ejemplo real de interacción

En el siguiente ejemplo, se abordan saludos, consultas sobre la próxima clase, horarios semanales, información de profesores de asignaturas y ubicaciones de despachos. Además, se manejan situaciones particulares, como la ausencia de un profesor en la base de datos o consultas relacionadas con asignaturas en las que el alumno no está matriculado.

<img title="" src="file:///Users/luiscrespoorti/Desktop/DGIIM/QUINTO/NUEVOS%20PARADIGMAS%20DE%20INTERACCIÓN/chat1.png" alt="Chat 1" width="303"> <img title="" src="file:///Users/luiscrespoorti/Desktop/DGIIM/QUINTO/NUEVOS%20PARADIGMAS%20DE%20INTERACCIÓN/chat2.png" alt="Chat 2" width="296">



<img title="" src="file:///Users/luiscrespoorti/Desktop/DGIIM/QUINTO/NUEVOS%20PARADIGMAS%20DE%20INTERACCIÓN/chat3.png" alt="Chat 1" width="300"> <img title="" src="file:///Users/luiscrespoorti/Desktop/DGIIM/QUINTO/NUEVOS%20PARADIGMAS%20DE%20INTERACCIÓN/chat4.png" alt="Chat 2" width="308">
