````markdown
# Prueba Técnica Exito - Flutter

Esta es una aplicación desarrollada en Flutter para la prueba técnica de manejo de productos y carrito de compras, con soporte de un modo express según horario configurado.

---

## **Cómo probar la app**

### 1. Ejecutando desde el código (modo desarrollador)

  1. Clona el repositorio:
  
  ```bash
  git clone <https://github.com/castano208/Prueba-Tecnica-Exito.git>
  cd <prueba_tecnica_exito_new>
  ````
  
  2. Instala las dependencias:
  
  ```bash
  flutter pub get
  ```
  
  3. Actualizar dependencias a sus últimas versiones mayores:
  
  ```bash
  flutter pub upgrade --major-versions
  ```
  
  4. Ejecuta la app en un emulador o dispositivo conectado:
  
  ```bash
  flutter run
  ```

---

## **APK**

* Además de la aplicación, se generó un archivo APK listo para instalar en dispositivos Android.
* Ruta del APK: `apk/app-release.apk`
* Solo es necesario copiarlo al dispositivo y abrirlo para instalar, sin requerir configuración adicional.

---

## **Notas importantes sobre el desarrollo**

* La app requiere conexión a Internet para cargar los productos.
* El **modo express** se activa con el switch que esta disponible según la hora local (entre 10:00 a.m y 16:00 p.m) Colombia/Bogota . Este modo utiliza un carrito independiente del modo normal.
* Los datos del carrito se sincronizan entre la vista de productos y la vista de carrito para cada modo, permitiendo mantener coherencia al agregar o quitar productos.

### **Mejoras realizadas en esta implementación (esto es algo que agregue aparte de lo pedido en la prueba se activa con el ojo en la parte inicial)**<img width="34" height="34" alt="image" src="https://github.com/user-attachments/assets/49cc965c-cb81-4902-ae65-e0bf43c4e559" />


1. **Input sincronizado con botones de cantidad:**

   * Además de los botones `+` y `-` para agregar o quitar productos, se implementó un **input editable** donde se puede ingresar directamente la cantidad deseada.
   * Este input se **sincroniza automáticamente** con los botones, de manera que los cambios en uno se reflejan en el otro.
   * Esta mejora aplica tanto en la vista de **productos por categoría** como en la vista de **carrito**, ofreciendo mayor rapidez y flexibilidad al usuario.

2. **Compatibilidad entre modos de carrito:**

   * Existen dos modos: normal y express.
   * Los carritos son independientes según el modo, pero ambos mantienen la misma lógica de sincronización entre input y botones.
   * La experiencia de usuario es consistente: puedes moverte entre productos y carrito en cualquier modo sin perder datos ni coherencia visual.
   * Visualmente, solo cambia el estilo según el modo, mientras la funcionalidad se mantiene idéntica.

3. **Valor agregado para la experiencia del usuario:**

   * La posibilidad de editar cantidades directamente en el input permite **agregar productos más rápido** que solo usando los botones.
   * Esto es especialmente útil cuando se manejan varias unidades de un producto o se busca eficiencia en el modo express.

---

## **Estructura del proyecto**

```
prueba_tecnica_exito/
│
├─ android/                # Configuración de Android
├─ ios/                    # Configuración de iOS
├─ lib/                    # Código Dart de la aplicación
├─ pubspec.yaml            # Configuración de dependencias
├─ README.md               # Este archivo
└─ build/app/outputs/flutter-apk/app-release.apk   # APK de release
```
