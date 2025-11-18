# Módulos del Sistema

## Estructura de la Tabla `modulos`

### Campos Requeridos

| Campo | Tipo | Descripción | Ejemplo |
|-------|------|-------------|---------|
| `id_modulo` | INT | ID único del módulo | `2` |
| `nombre` | VARCHAR | Nombre visible en el sidebar | `"Reservaciones"` |
| `descripcion` | VARCHAR | Descripción del módulo | `"Reservaciones clientes"` |
| `icono` | VARCHAR | Código hexadecimal del Material Icon | `"0xe3c9"` |
| `ruta` | VARCHAR | Identificador único para mapear a pantalla | `"reservaciones_cliente"` |

---

## Módulos Disponibles

### 1. Reservaciones

```json
{
  "id_modulo": 2,
  "nombre": "Reservaciones",
  "descripcion": "Reservaciones clientes",
  "icono": "0xe3c9",
  "ruta": "reservaciones_cliente"
}
```

**Identificadores de ruta válidos:**
- `reservaciones_cliente`
- `reservaciones`

**Pantalla:** UnderConstructionScreen (en construcción)

---

### 2. Reportar Incidencia / Incidencias

```json
{
  "id_modulo": 3,
  "nombre": "Reportar Incidencia",
  "descripcion": "Reportes de clientes",
  "icono": "0xe869",
  "ruta": "incidencias_list"
}
```

**Identificadores de ruta válidos:**
- `incidencias_list`
- `incidencias`
- `reportar_incidencia`
- `reportes_cliente`

**Pantalla:** IncidenciasListScreen

---

### 3. Clientes

```json
{
  "id_modulo": 4,
  "nombre": "Clientes",
  "descripcion": "Gestión de clientes",
  "icono": "0xe7ef",
  "ruta": "clientes_list"
}
```

**Identificadores de ruta válidos:**
- `clientes_list`
- `clientes`

**Pantalla:** ClientesListScreen

---

### 4. Hoteles

```json
{
  "id_modulo": 5,
  "nombre": "Hoteles",
  "descripcion": "Gestión de hoteles",
  "icono": "0xe549",
  "ruta": "hotels_list"
}
```

**Identificadores de ruta válidos:**
- `hotels_list`
- `hoteles`

**Pantalla:** HotelsListScreen

---

## Códigos de Iconos Material Icons

| Icono | Código Hexadecimal | Nombre Material Icon |
|-------|-------------------|---------------------|
| Reservaciones | `0xe3c9` | `Icons.event_available` |
| Incidencias/Reportes | `0xe869` | `Icons.report` |
| Clientes | `0xe7ef` | `Icons.person` |
| Hoteles | `0xe549` | `Icons.hotel` |
| Dashboard | `0xe871` | `Icons.dashboard` |
| Lista | `0xe896` | `Icons.list` |

---

## Notas Importantes

1. **Campo `ruta`**: Debe usar identificadores en minúsculas con guiones bajos (snake_case)
2. **Campo `icono`**: Debe contener el código hexadecimal del Material Icon (ej: `"0xe3c9"`)
3. **Campo `nombre`**: Texto legible que se mostrará en el sidebar
4. Si un módulo no tiene un mapeo definido, se mostrará una pantalla genérica (UnderConstructionScreen) con el nombre del módulo

---

## Ejemplo de Respuesta del Backend

```json
{
  "access_token": "...",
  "token_type": "bearer",
  "expires_in": 12600,
  "usuario": {
    "id_usuario": 1,
    "login": "ClienTest",
    "correo_electronico": "xgperez97@gmail.com"
  },
  "modulos": [
    {
      "id_modulo": 2,
      "nombre": "Reservaciones",
      "descripcion": "Reservaciones clientes",
      "icono": "0xe3c9",
      "ruta": "reservaciones_cliente"
    },
    {
      "id_modulo": 3,
      "nombre": "Reportar Incidencia",
      "descripcion": "Reportes de clientes",
      "icono": "0xe869",
      "ruta": "incidencias_list"
    }
  ],
  "roles": [
    {
      "id_rol": 1,
      "rol": "Cliente"
    }
  ]
}
```

