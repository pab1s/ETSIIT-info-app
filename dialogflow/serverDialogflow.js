const express = require('express');
const sqlite3 = require('sqlite3');
const http = require('http');
const path = require('path');
const { WebhookClient } = require('dialogflow-fulfillment');
const app = express();
const port = 3000;

// Conectar a la base de datos SQLite
const dbPath = path.join(__dirname, 'bd', 'usuarios.db');
const db = new sqlite3.Database(dbPath, sqlite3.OPEN_READWRITE, (err) => {
    if (err) {
        console.error(err.message);
    }
    console.log('Conectado a la base de datos SQLite.');
});

app.get('/', (req, res) => {
    res.send('Servidor funcionando correctamente.');
});

// Iniciar el servidor
app.listen(port, () => {
    console.log(`Servidor escuchando en http://localhost:${port}`);
});

app.get('/api/horariosemanal', async (req, res) => {
    let nombreAsignatura = req.query.asignatura;
    const nombreAsignaturaNormalizado = nombreAsignatura.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");

    try {
        const matriculas = await new Promise((resolve, reject) => {
            db.all("SELECT * FROM matriculas WHERE username = 'ximosanz'", [], (err, rows) => {
                if (err) {
                    reject(err.message);
                } else {
                    resolve(rows);
                }
            });
        });

        const horariosPorAsignatura = {};
        for (const matricula of matriculas) {
            const asignatura = await new Promise((resolve, reject) => {
                db.get("SELECT * FROM asignaturas WHERE indice = ?", [matricula.indice], (err, asignatura) => {
                    if (err) {
                        console.error(err.message);
                        reject(err.message);
                    } else {
                        resolve(asignatura);
                    }
                });
            });

            if (asignatura && asignatura.asignatura.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "").includes(nombreAsignaturaNormalizado)) {
                const nombreAsig = asignatura.asignatura;
                const dia = asignatura.dia_de_la_semana;

                if (!horariosPorAsignatura[nombreAsig]) {
                    horariosPorAsignatura[nombreAsig] = {};
                }
                if (!horariosPorAsignatura[nombreAsig][dia]) {
                    horariosPorAsignatura[nombreAsig][dia] = [];
                }

                horariosPorAsignatura[nombreAsig][dia].push({
                    hora_inicio: asignatura.hora_inicio,
                    hora_fin: asignatura.hora_fin
                });
            }
        }


       // Función para comparar horas en formato HH:MM:SS
        const compararHoras = (a, b) => {
            const [horaA, minutoA, segundoA] = a.hora_inicio.split(':').map(Number);
            const [horaB, minutoB, segundoB] = b.hora_inicio.split(':').map(Number);
            return horaA - horaB || minutoA - minutoB || segundoA - segundoB;
        };

        // Ordenar los horarios por hora de inicio
        for (const asignatura in horariosPorAsignatura) {
            for (const dia in horariosPorAsignatura[asignatura]) {
                horariosPorAsignatura[asignatura][dia].sort(compararHoras);
            }
        }

        // Ordenar los días de la semana
        const ordenDias = ['Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo'];
        const horariosOrdenadosPorDia = {};
        for (const asignatura in horariosPorAsignatura) {
            const diasHorarios = horariosPorAsignatura[asignatura];
            horariosOrdenadosPorDia[asignatura] = ordenDias
                .filter(dia => diasHorarios.hasOwnProperty(dia))
                .reduce((obj, dia) => {
                    obj[dia] = diasHorarios[dia];
                    return obj;
                }, {});
        }

        res.json(horariosOrdenadosPorDia);
    } catch (error) {
        res.status(500).send('Error en la base de datos');
    }
});

app.get('/api/profesores', async (req, res) => {
    let nombreAsignatura = req.query.asignatura;
    const nombreAsignaturaNormalizado = nombreAsignatura.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");

    try {
        const matriculas = await new Promise((resolve, reject) => {
            db.all("SELECT * FROM matriculas WHERE username = 'ximosanz'", [], (err, rows) => {
                if (err) reject(err.message);
                else resolve(rows);
            });
        });

        const profesoresPorAsignatura = {};
        for (const matricula of matriculas) {
            const asignatura = await new Promise((resolve, reject) => {
                db.get("SELECT * FROM asignaturas WHERE indice = ?", [matricula.indice], (err, asignatura) => {
                    if (err) reject(err.message);
                    else resolve(asignatura);
                });
            });

            if (asignatura && asignatura.asignatura.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "").includes(nombreAsignaturaNormalizado)) {
                const nombreAsig = asignatura.asignatura;
                const infoProfesor = {
                    profesor: asignatura.profesor,
                    tipo_de_grupo: asignatura.tipo_de_grupo
                };

                if (!profesoresPorAsignatura[nombreAsig]) {
                    profesoresPorAsignatura[nombreAsig] = [];
                }
                if (!profesoresPorAsignatura[nombreAsig].find(p => p.profesor === infoProfesor.profesor && p.tipo_de_grupo === infoProfesor.tipo_de_grupo)) {
                    profesoresPorAsignatura[nombreAsig].push(infoProfesor);
                }
            }
        }

        res.json(profesoresPorAsignatura);
    } catch (error) {
        res.status(500).send('Error en la base de datos');
    }
});



app.get('/api/despachos', async (req, res) => {
    let nombreProfesor = req.query.nombre;

    // Normalizar el nombre del profesor para la comparación
    const nombreProfesorNormalizado = nombreProfesor.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");

    try {
        const profesores = await new Promise((resolve, reject) => {
            db.all("SELECT * FROM profesores", [], (err, rows) => {
                if (err) {
                    reject(err.message);
                } else {
                    const coincidentes = rows.filter(prof => 
                        prof.nombre.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "")
                        .includes(nombreProfesorNormalizado));
                    resolve(coincidentes);
                }
            });
        });

        res.json(profesores);
    } catch (error) {
        res.status(500).send('Error en la base de datos');
    }
});



app.get('/api/proximaclase', async (req, res) => {
    try {
        const matriculas = await new Promise((resolve, reject) => {
            db.all('SELECT * FROM matriculas WHERE username = "ximosanz"', [], (err, matriculas) => {
                if (err) {
                    reject('Error en la base de datos');
                } else {
                    resolve(matriculas);
                }
            });
        });

        if (matriculas.length === 0) {
            res.status(404).send('No se encontraron matrículas para el usuario "ximosanz"');
            return;
        }

        const currentDate = new Date();
        const currentDay = capitalizeFirstLetterAndRemoveAccents(currentDate.toLocaleDateString('es-ES', { weekday: 'long' }));
        const currentTime = currentDate.toLocaleTimeString('es-ES', { hour12: false });

        let closestAssignment = null;
        let closestTimeDiff = Infinity;

        for (const matricula of matriculas) {
            const indice = matricula.indice;
            const asignatura = await new Promise((resolve, reject) => {
                db.get('SELECT * FROM asignaturas WHERE indice = ?', [indice], (err, asignatura) => {
                    if (err) {
                        console.error(err.message);
                        reject(err.message);
                    } else {
                        resolve(asignatura);
                    }
                });
            });

            if (!asignatura) {
                continue;
            }

            const diaSemana = asignatura.dia_de_la_semana;
            const horaInicio = asignatura.hora_inicio;

            // Calcula la diferencia de tiempo en minutos
            const timeDiff = calculateTimeDifference(currentDay, diaSemana, currentTime, horaInicio);

            if (timeDiff >= 0 && timeDiff < closestTimeDiff) {
                closestTimeDiff = timeDiff;
                closestAssignment = asignatura;
            }
        }

        if (closestAssignment) {
            res.json({ asignatura: closestAssignment, minutos_hasta_la_clase: closestTimeDiff });
        } else {
            res.status(404).send('No se encontraron asignaturas para el usuario "ximosanz"');
        }
    } catch (error) {
        res.status(500).send('Error en la base de datos');
    }
});


function capitalizeFirstLetterAndRemoveAccents(inputString) {
    const accentMap = {
        á: 'a',
        é: 'e',
    };

    const normalizedString = inputString.replace(/[áé]/g, (match) => accentMap[match] || match);

    // Capitaliza la primera letra
    const firstLetterCapitalized = normalizedString.charAt(0).toUpperCase();

    return firstLetterCapitalized + normalizedString.slice(1);
}


function calculateTimeDifference(currentDay, targetDay, currentTime, targetTime) {
    // Convierte los días de la semana a índices numéricos (Lunes = 1, Martes = 2, etc.)
    const daysOfWeek = ['Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo'];
    const currentDayIndex = daysOfWeek.indexOf(currentDay);
    const targetDayIndex = daysOfWeek.indexOf(targetDay);

    // Parsea las horas y minutos
    let [currentHour, currentMinute] = currentTime.split(':').map(Number);
    let [targetHour, targetMinute] = targetTime.split(':').map(Number);

    currentHour = (currentHour + 1) % 24

    // Calcula la diferencia en minutos
    if(targetDayIndex - currentDayIndex < 0)
        daysDiff = targetDayIndex - currentDayIndex + 7
    else
        daysDiff = targetDayIndex - currentDayIndex


    let timeDiff = daysDiff * 24 * 60;
    timeDiff += (targetHour - currentHour) * 60;
    timeDiff += targetMinute - currentMinute;

    return timeDiff;
}

function respuestaAleatoria(respuestas) {
    return respuestas[Math.floor(Math.random() * respuestas.length)];
}


app.post('/webhook', express.json(), (req, res) => {
    const agent = new WebhookClient({ request: req, response: res });

    function welcome(agent) {
        agent.add('Welcome to my agent!');
    }

    function fallback(agent) {
        agent.add('I didn\'t understand');
        agent.add('I\'m sorry, can you try again?');
    }

    function makeHttpRequest(url) {
        return new Promise((resolve, reject) => {
            http.get(url, (response) => {
                let data = '';

                // Verificar el código de estado de la respuesta
                if (response.statusCode < 200 || response.statusCode > 299) {
                    reject(new Error('Failed to load page, status code: ' + response.statusCode));
                    return;
                }

                response.on('data', (chunk) => {
                    data += chunk;
                });

                response.on('end', () => {
                    resolve(data);
                });
            }).on('error', (error) => {
                reject(error);
            });
        });
    }

    async function proximaclase(agent) {
        const url = 'http://localhost:3000/api/proximaclase';
        try {
            const data = await makeHttpRequest(url);
            const jsonData = JSON.parse(data);

            if (jsonData.asignatura) {
                const asignatura = jsonData.asignatura;
                // Extraer las horas y minutos de inicio y fin sin los segundos
                let horaInicio = asignatura.hora_inicio.split(':').slice(0, 2).join(':');
                let horaFin = asignatura.hora_fin.split(':').slice(0, 2).join(':');

                const respuestas = [
                `Tu próxima asignatura es ${asignatura.tipo_de_grupo} de ${asignatura.asignatura} (grupo ${asignatura.grupo}), el ${asignatura.dia_de_la_semana} de ${horaInicio} a ${horaFin}`,
                `La siguiente clase que tienes es ${asignatura.tipo_de_grupo} de ${asignatura.asignatura} (grupo ${asignatura.grupo}), el ${asignatura.dia_de_la_semana} desde ${horaInicio} hasta ${horaFin}`,
                `${asignatura.tipo_de_grupo} de ${asignatura.asignatura}, en el grupo ${asignatura.grupo}, que es el ${asignatura.dia_de_la_semana} de ${horaInicio} a ${horaFin}`
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

    async function preguntarDespacho(agent) {
        let nombreProfesor = agent.parameters.person ? agent.parameters.person.name : null;

        // Si no se ha proporcionado un parámetro, verificar el contexto
        if (!nombreProfesor) {
            const contextoAsignatura = agent.context.get('asignatura_info');
            
            // Verificar si el contexto contiene un array de profesores
            if (contextoAsignatura && Array.isArray(contextoAsignatura.parameters.profesorAsignatura)) {
                let nombresProfesores = contextoAsignatura.parameters.profesorAsignatura;
                
                // Si hay varios profesores, preguntar al usuario a cuál se refiere
                if (nombresProfesores.length > 1) {
                    let pregunta = `¿Te refieres a ${nombresProfesores.slice(0, -1).join(', ')} o ${nombresProfesores.slice(-1)}?`;
                    agent.add(pregunta);
                    return;
                } else {
                    // Si solo hay un profesor en el contexto
                    nombreProfesor = nombresProfesores[0];
                }

            } else if (contextoAsignatura) {
                // Usar el nombre del profesor del contexto si está disponible
                nombreProfesor = contextoAsignatura.parameters.profesorAsignatura;
            }
        }

        // Continuar si se ha determinado un nombre de profesor
        if (nombreProfesor) {
            const url = `http://localhost:3000/api/despachos?nombre=${encodeURIComponent(nombreProfesor)}`;

            try {
                const data = await makeHttpRequest(url);
                const jsonData = JSON.parse(data);

                if (jsonData.length > 1) {
                    // Múltiples profesores encontrados con el mismo nombre
                    let nombresProfesores = jsonData.map(prof => prof.nombre);
                    let pregunta = `¿Te refieres a ${nombresProfesores.slice(0, -1).join(', ')} o ${nombresProfesores.slice(-1)}?`;
                    agent.add(pregunta);
                } else if (jsonData.length === 1) {
                    // Un solo profesor encontrado
                    const respuestas = [
                        `El profesor ${jsonData[0].nombre} trabaja en ${jsonData[0].despacho}`,
                        `Puedes encontrar a ${jsonData[0].nombre} en el despacho ${jsonData[0].despacho}`
                    ];
                    agent.add(respuestaAleatoria(respuestas));
                } else {
                    // Ningún profesor encontrado
                    agent.add('No se han encontrado profesores con ese nombre en la ETSIIT.');
                }
            } catch (error) {
                console.error(error);
                agent.add('Hubo un error al obtener la información de los profesores');
            }
        } else {
            // No se proporcionó un nombre de profesor ni se encontró en el contexto
            agent.add('Por favor, dime el nombre del profesor.');
            return;
        }
    }


    async function horarioAsignaturas(agent) {
        let nombreAsignatura = agent.parameters.asignatura;

        // Verificar si hay un contexto activo y obtener el nombre de la asignatura de él
        const contextoAsignatura = agent.context.get('asignatura_info');
        if (!nombreAsignatura && contextoAsignatura) {
            nombreAsignatura = contextoAsignatura.parameters.nombreAsignatura;
        }

        if (!nombreAsignatura) {
            agent.add('Por favor, dime el nombre de la asignatura.');
            return;
        }

        try {
            const url = `http://localhost:3000/api/horariosemanal?asignatura=${encodeURIComponent(nombreAsignatura)}`;
            const data = await makeHttpRequest(url);
            const jsonData = JSON.parse(data);

            if (Object.keys(jsonData).length > 1) {
                // Múltiples asignaturas encontradas
                let nombresAsignaturas = Object.keys(jsonData);
                let pregunta = `¿Te refieres a ${nombresAsignaturas.slice(0, -1).join(', ')} o ${nombresAsignaturas.slice(-1)}?`;
                agent.add(pregunta);
            } else if (Object.keys(jsonData).length === 1) {
                let nombre = Object.keys(jsonData)[0];
                let diasHorarios = jsonData[nombre];
                let diasTexto = Object.keys(diasHorarios).map((dia, index, array) => {
                    let horariosDia = diasHorarios[dia].map(h => {
                        // Extraer las horas y minutos de inicio y fin sin los segundos
                        let horaInicio = h.hora_inicio.split(':').slice(0, 2).join(':');
                        let horaFin = h.hora_fin.split(':').slice(0, 2).join(':');
                        return `de ${horaInicio} a ${horaFin}`;
                    });
                    let textoDia;
                    if (horariosDia.length > 1) {
                        let ultimoHorario = horariosDia.pop();
                        textoDia = horariosDia.join(', ') + ' y ' + ultimoHorario;
                    } else {
                        textoDia = horariosDia.join('');
                    }
                    return `${index === array.length - 1 && array.length > 1 ? 'y ' : ''}los ${dia} ${textoDia}`;
                }).join('; ');

                const respuestas = [
                    `Tienes clase de ${nombre} ${diasTexto}`,
                    `Este cuatrimestre, cursas la asignatura ${nombre} ${diasTexto}`,
                    `Tu horario de ${nombre} es ${diasTexto}`]

                agent.add(respuestaAleatoria(respuestas));

                agent.context.set({
                    name: 'asignatura_info',
                    lifespan: 3, 
                    parameters: {
                        nombreAsignatura: nombre,
                        profesorAsignatura: null,
                        tipoGrupoAsignatura: null
                    }
                });
            } 
            else {
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
            agent.add('Hubo un error al obtener el horario de las asignaturas');
        }
    }


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


    const intentMap = new Map();
    intentMap.set('HorarioAsignaturas', horarioAsignaturas);
    intentMap.set('PreguntarDespacho', preguntarDespacho);
    intentMap.set('Default Welcome Intent', welcome);
    intentMap.set('Default Fallback Intent', fallback);
    intentMap.set('ProximaClase', proximaclase);
    intentMap.set('PreguntarProfesorAsignatura', preguntarProfesorAsignatura);
    agent.handleRequest(intentMap);
});