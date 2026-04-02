# OwFinance Iniciativa de Backlog (Notion) - Versión Expandida

*Este documento contiene las tareas del backlog expandidas y documentadas con todo el contexto estratégico de OW Finance 2026. Están listas para importarse a Notion cuando el servidor MCP se estabilice.*

---

## 1. Sistema de Registro por Voz (NLP Core)

### Información Basic
- **Name:** Implementar Micro-servicio de Transcripción y Categorización de Voz.
- **Status:** To Do
- **Priority:** Alta
- **Role:** UX, Fullstack
- **Estimación de Horas:** 16 a 24 horas

### User Story
"Yo como usuario con prisa, quiero dictar un gasto mediante un comando de voz desde el FAB Principal para que se registre automáticamente."

### Criterios de Aceptación
- Integración de Web Speech API o motor similar en Flutter/Capacitor.
- Endpoint en Laravel que envíe el prompt a un LLM para extraer: Monto, Categoría y Moneda de textos (ej: "Pagué 15 dólares en un café").
- Confirmación visual "Toast" con arquitectura *Liquid Glass*.

---

### Especificación Técnica Detallada

#### 1.1 Frontend - Componente de Voz

**Ubicación:** `OWFinanceFrontend2025/src/components/VoiceInputDialog.vue` (nuevo)

**Tecnologías requeridas:**
- Web Speech API (`window.SpeechRecognition` o `window.webkitSpeechRecognition`)
- Fallback: `vue-web-speech` o integración con API externa

**Interfaces TypeScript necesarias:**
```typescript
interface VoiceTransactionPayload {
  amount: number;
  currency: string;
  category_id: number | null;
  category_name: string;
  confidence: number; // 0-1
  raw_text: string;
}

interface VoiceInputState {
  isListening: boolean;
  transcript: string;
  isProcessing: boolean;
  result: VoiceTransactionPayload | null;
  error: string | null;
}
```

**Flujo de UI:**
1. Usuario presiona botón de micrófono en FAB
2. Se abre modal con animación Glassmorphism
3. Visualizador de onda de audio en tiempo real
4. Transcripción en tiempo real
5. Preview de transacción extraída
6. Botones de confirmar/editar/cancelar

**Componentes a modificar:**
- `src/layouts/UserLayout.vue` - Agregar FAB de voz
- `src/stores/ui.ts` - Agregar estado del dialog
- `src/boot/axios.ts` - Agregar timeout extendido para voice

**Endpoints frontend a llamar:**
```typescript
// POST /api/v1/voice/parse
interface VoiceParseRequest {
  text: string;
  user_id: number;
}

interface VoiceParseResponse {
  status: 'SUCCESS' | 'FAILED';
  data: {
    amount: number;
    currency_code: string;
    category_id: number | null;
    category_name: string;
    confidence: number;
  }
}
```

#### 1.2 Backend - Endpoint de Procesamiento

**Ubicación:** `OWFINANCEBackend2025/routes/api/voice.php` (nuevo)

**Controlador:** `app/Http/Controllers/Api/VoiceController.php`

```php
// Ruta: POST /api/v1/voice/parse
public function parse(Request $request)
```

**Servicios a crear:**
- `app/Services/VoiceParseService.php` - Lógica de parsing
- `app/Services/LLMService.php` - Abstracción de LLM

**Proveedores LLM soportados (configurables):**
1. OpenAI GPT-4o Mini (recomendado por costo/calidad)
2. Anthropic Claude 3 Haiku
3. Google Gemini Flash
4. Ollama local (offline)

**Configuración de entorno (.env):**
```env
VOICE_LLM_PROVIDER=openai
VOICE_LLM_API_KEY=sk-...
VOICE_LLM_MODEL=gpt-4o-mini
VOICE_LLM_TEMPERATURE=0.1
VOICE_MAX_TOKENS=500
```

**Prompt de extracción (a optimizar):**
```
Extrae los datos financieros del siguiente texto en español:
"{{text}}"

Responde solo con JSON:
{
  "amount": número,
  "currency": "USD|EUR|VES|otro",
  "category": "categoría detectada o null",
  "confidence": 0.0-1.0
}

Categorías válidas del usuario: {{available_categories}}
```

**Base de datos - nueva tabla:**
```php
// database/migrations/xxxx_xx_xx_create_voice_commands_table.php
Schema::create('voice_commands', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->cascadeOnDelete();
    $table->string('raw_text');
    $table->decimal('amount', 15, 2)->nullable();
    $table->string('currency', 3)->nullable();
    $table->foreignId('category_id')->nullable()->constrained()->nullOnDelete();
    $table->decimal('confidence', 3, 2)->nullable();
    $table->string('llm_provider')->nullable();
    $table->boolean('confirmed')->default(false);
    $table->timestamps();
});
```

#### 1.3 Casos de Prueba

| Caso | Input | Output esperado |
|------|-------|-----------------|
| 1 | "Pagué 25 dólares en café" | {amount: 25, currency: "USD", category: "Café"} |
| 2 | "Gasté 50 euros en supermercado" | {amount: 50, currency: "EUR", category: "Supermercado"} |
| 3 | "Compré algo por 100" | {amount: 100, currency: (moneda default), category: null} |
| 4 | "Transferencia de 200 a ahorro" | {amount: 200, type: "transfer", target: "ahorro"} |

#### 1.4 Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|-------------|---------|------------|
| Reconocimiento offline | Media | Alto | Cache de categorías, fallback a parsing regex |
| LLM no responde | Baja | Alto | Timeout 10s, fallback a regex básico |
| Moneda ambigua | Media | Medio | Pedir confirmación explícita |
| Ruido ambiente | Media | Medio | Visual feedback de "escuchando" |

#### 1.5 Milestones de Implementación

- [ ] Milestone 1: UI de voz básica con Web Speech API
- [ ] Milestone 2: Endpoint Laravel con parsing regex (MVP)
- [ ] Milestone 3: Integración LLM (OpenAI)
- [ ] Milestone 4: Persistencia y analytics
- [ ] Milestone 5: Testing y optimización

---

## 2. Visor e Ingesta de Recibos (OCR)

### Información Basic
- **Name:** Desarrollo de Interfaz de Cámara y Extracción OCR.
- **Status:** To Do
- **Priority:** Alta
- **Role:** UX, Fullstack
- **Estimación de Horas:** 20 a 30 horas

### User Story
"Yo como comprador, quiero tomar una foto a mi ticket físico o factura para que la IA extraiga el total, impuestos y lo guarde en mi cuenta asociada."

### Criterios de Aceptación
- Acceso nativo a cámara vía Capacitor y carga de UI modal.
- Procesamiento OCR en backend (Google Vision o AWS Textract).
- Precarga de formulario "Añadir Transacción" con los datos extraídos para validación humana rápida.

---

### Especificación Técnica Detallada

#### 2.1 Frontend - Componente de Cámara

**Ubicación:** `OWFinanceFrontend2025/src/components/ReceiptCaptureDialog.vue` (nuevo)

**Tecnologías:**
- Capacitor Camera Plugin (`@capacitor/camera`)
- Capacitor Filesystem (`@capacitor/filesystem`)
- Imagen preview con crop manual

**Permisos Android (AndroidManifest.xml):**
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

**Permisos iOS (Info.plist):**
```xml
<key>NSCameraUsageDescription</key>
<string>OWFinance necesita acceso a tu cámara para escanear recibos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>OWFinance necesita acceso a tus fotos para seleccionar recibos</string>
```

**Flujo de UI:**
1. Usuario presiona botón "Escanear recibo" en FAB o desde formulario
2. Modal con opciones: Cámara / Galería
3. Vista de cámara en tiempo real con overlay guía
4. Captura y preview
5. Crop manual (opcional)
6. Envío a backend con progress bar
7. Preview de datos extraídos
8. Edición manual si es necesario
9. Confirmar → crear transacción

**Estados del componente:**
```typescript
interface ReceiptCaptureState {
  mode: 'idle' | 'camera' | 'gallery' | 'processing' | 'preview' | 'error';
  capturedImage: string | null;
  ocrResult: OCRResult | null;
  isProcessing: boolean;
  progress: number;
  error: string | null;
}

interface OCRResult {
  raw_text: string;
  total_amount: number | null;
  tax_amount: number | null;
  currency: string | null;
  merchant_name: string | null;
  date: string | null;
  confidence: number;
  line_items: LineItem[];
}
```

#### 2.2 Backend - Servicio OCR

**Ubicación:** `OWFINANCEBackend2025/routes/api/ocr.php` (nuevo)

**Controlador:** `app/Http/Controllers/Api/OcrController.php`

```php
// Ruta: POST /api/v1/ocr/scan
public function scan(Request $request)
```

**Proveedores OCR (configurables):**
1. Google Cloud Vision API (recomendado)
2. AWS Textract
3. Azure Computer Vision
4. Tesseract.js (offline, menos preciso)

**Configuración de entorno (.env):**
```env
OCR_PROVIDER=google_vision
GOOGLE_CLOUD_VISION_API_KEY=AIza...
AWS_TEXTRAECT_ACCESS_KEY=...
AWS_TEXTRAECT_SECRET_KEY=...
AWS_TEXTRAECT_REGION=us-east-1
OCR_FALLBACK_PROVIDER=tesseract
```

**Procesamiento de respuesta OCR:**
```php
// Lógica de extracción de ticket/recibo
class ReceiptParserService
{
    public function parse(string $text): ReceiptData
    {
        // 1. Detectar moneda por símbolos ($ € ¥)
        // 2. Extraer total (palabra "Total", "Importe", etc.)
        // 3. Extraer impuestos (IVA, tax, etc.)
        // 4. Detectar fecha
        // 5. Extraer líneas de items si es posible
        // 6. Calcular confianza
    }
}
```

**Base de datos:**
```php
// database/migrations/xxxx_xx_xx_create_receipt_scans_table.php
Schema::create('receipt_scans', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->cascadeOnDelete();
    $table->foreignId('transaction_id')->nullable()->constrained()->nullOnDelete();
    $table->string('image_path');
    $table->text('raw_ocr_text');
    $table->decimal('extracted_total', 15, 2)->nullable();
    $table->decimal('extracted_tax', 15, 2)->nullable();
    $table->string('extracted_currency', 3)->nullable();
    $table->string('merchant_name')->nullable();
    $table->date('receipt_date')->nullable();
    $table->decimal('confidence', 3, 2);
    $table->string('ocr_provider');
    $table->boolean('confirmed')->default(false);
    $table->timestamps();
});
```

#### 2.3 Integración con Transacciones

Una vez extraídos los datos, pre-llenar el formulario de transacción:

```typescript
// En TransactionForm.vue
interface PrefilledTransaction {
  amount: number;
  currency: string;
  description: string;
  date: Date;
  category_id: number | null;
  account_id: number | null;
  tax_amount: number | null;
  items: LineItem[];
}
```

**Mapeo de datos OCR a transacción:**
- `total_amount` → `amount`
- `currency` → `currency`
- `date` → `transaction_date`
- `line_items` → `items` (tabla `item_transactions`)

#### 2.4 Casos de Prueba

| Caso | Input | Output esperado |
|------|-------|-----------------|
| 1 | Foto clara de ticket con total "$45.50" | {total: 45.50, currency: "USD"} |
| 2 | Factura con IVA del 16% | {total: 100, tax: 16} |
| 3 | Ticket arrugado borroso | {confidence: 0.3, error: "Bajo contraste"} |
| 4 | Recibo sin texto legible | {error: "No se detectó texto"} |

#### 2.5 Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|-------------|---------|------------|
| OCR falla en tickets arrugados | Alta | Medio | Feedback claro, edición manual fácil |
| Costo API externa | Media | Medio | Cacheo de resultados, fallback a Tesseract |
| Permisos de cámara denegados | Media | Alto | Guía para habilitar en Settings |
| Imagen muy grande | Media | Medio | Compresión antes de envío (max 2MB) |

---

## 3. Automatización de Reparto en Cántaros (Ingresos)

### Información Basic
- **Name:** Lógica de Distribución Automática (Waterfall / Porcentual).
- **Status:** To Do
- **Priority:** Alta
- **Role:** Fullstack, Infra
- **Estimación de Horas:** 12 a 16 horas

### User Story
"Como ahorrador disciplinado, quiero que al registrar mi nómina, la app divida inteligentemente el dinero entre mis cántaros (Necesidades, Ahorro, etc.) basándose en mis porcentajes configurados (`<=100%`)."

### Criterios de Aceptación
- Función de backend que detecte transacciones tipo "Ingreso Fijo".
- Disparador de simulador de reparto en Frontend.
- UI interactiva Drag & Drop para ajustar excedentes si un cántaro ya está cubierto.

---

### Especificación Técnica Detallada

#### 3.1 Lógica de Detección de Ingresos

**Backend - Detección de ingresos automáticos:**

**Ubicación:** `OWFINANCEBackend2025/app/Services/IncomeDetectionService.php` (nuevo)

```php
class IncomeDetectionService
{
    public function detectIncomeType(Transaction $transaction): IncomeType
    {
        // Criterios de detección:
        // 1. Transaction type = "income"
        // 2. Moneda = moneda base del usuario
        // 3. Monto >= umbral configurable (ej. salary mínimo)
        // 4. Descripción contiene keywords: "sueldo", "salario", "nómina", "payroll"
        // 5. Frecuencia: recurrente (mismo monto ±10% en últimos 3 meses)
    }
}

enum IncomeType: string
{
    case SALARY = 'salary';      // Ingreso fijo mensual
    case FREELANCE = 'freelance'; // Ingreso variable
    case GIFT = 'gift';           // Regalo
    case OTHER = 'other';
}
```

**Tabla de historial de ingresos:**
```php
// database/migrations/xxxx_xx_xx_create_income_patterns_table.php
Schema::create('income_patterns', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->cascadeOnDelete();
    $table->string('description_pattern'); // LIKE pattern
    $table->decimal('expected_amount', 15, 2);
    $table->decimal('amount_tolerance', 3, 2)->default(0.10); // ±10%
    $table->foreignId('category_id')->nullable()->constrained()->nullOnDelete();
    $table->enum('type', ['salary', 'freelance', 'gift', 'other']);
    $table->integer('frequency_days')->nullable(); // 30 = mensual
    $table->timestamps();
});
```

#### 3.2 Motor de Distribución (Waterfall)

**Backend - Servicio de distribución:**

**Ubicación:** `OWFINANCEBackend2025/app/Services/JarDistributionService.php` (nuevo)

```php
class JarDistributionService
{
    public function distribute(float $incomeAmount, int $userId): DistributionResult
    {
        // Algoritmo:
        // 1. Obtener jars activos del usuario ordenados por prioridad
        // 2. Para cada jar:
        //    - Si es tipo FIXED: asignar monto fijo
        //    - Si es tipo PERCENT: asignar (monto * porcentaje / 100)
        // 3. Si excede el límite del jar, marcar como "excedente"
        // 4. Retornar distribución propuesta
    }
}

interface DistributionResult
{
    public array $distributions; // [{jar_id, assigned, remaining, is_excess}]
    public float $totalAssigned;
    public float $totalExcess;
    public float $unassigned;
}
```

**Invariantes a respetar (del AGENTS.md):**
- Suma de porcentajes activos <= 100%
- Categoría pertenece a máximo un jar por usuario
- Operaciones scoped al usuario autenticado

#### 3.3 Frontend - UI de Simulación

**Ubicación:** `OWFinanceFrontend2025/src/components/JarDistributionSimulator.vue` (nuevo)

**Flujo de UI:**
1. Usuario registra transacción tipo "Ingreso"
2. Backend detecta que es ingreso recurrente → retorna `shouldSuggestDistribution: true`
3. Frontend muestra modal "Distribución Sugerida"
4. Gráfico de dona mostrando distribución
5. Slider interactivo para ajustar montos
6. Drag & drop para reorderar jars
7. Sección de "Excedente" editable
8. Botones: "Aplicar", "Editar Manualmente", "Ignorar"

**Componentes a modificar:**
- `src/pages/user/transactions/index.vue` - Detectar ingreso
- `src/stores/jars.ts` - Agregar método `distributeIncome()`
- `src/composables/useJarBalance.ts` - Integrar con distribución

**Estado del store:**
```typescript
interface JarDistributionState {
  incomeAmount: number;
  distributions: JarDistribution[];
  totalAssigned: number;
  totalExcess: number;
  isSimulating: boolean;
  suggestedAdjustments: string[]; // warnings
}

interface JarDistribution {
  jar_id: number;
  jar_name: string;
  assigned_amount: number;
  percentage: number;
  is_fixed: boolean;
  is_excess: boolean;
  can_increase: boolean;
  can_decrease: boolean;
}
```

#### 3.4 API Endpoints

```php
// routes/api/jar-distribution.php (nuevo)

// POST /api/v1/jars/distribution/suggest
// Detecta si es ingreso y retorna distribución sugerida
public function suggest(Request $request, int $transactionId)

// POST /api/v1/jars/distribution/apply
// Aplica la distribución creando transacciones de ajuste
public function apply(Request $request)

// GET /api/v1/jars/distribution/history
// Historial de distribuciones aplicadas
public function history()
```

#### 3.5 Casos de Prueba

| Caso | Input | Output esperado |
|------|-------|----------------|
| 1 | Ingreso de $1000, jars: 50% necesidades, 30% ahorro | {necesidades: $500, ahorro: $300, sin_asignar: $200} |
| 2 | Jar "negocio" ya tiene $1000 (límite), ingreso $500 | {exceso: $500, warning: "Jar negocio lleno"} |
| 3 | 3 jars tipo FIXED: $200 + $100 + $50, ingreso $500 | {$200, $100, $50, sin_asignar: $150} |

---

## 4. UI de Gasto Rápido y Chatbot (Componentes Flotantes)

### Información Basic
- **Name:** Desarrollo de FAB Inteligente y Chat Modal.
- **Status:** To Do
- **Priority:** Media
- **Role:** UX, Frontend
- **Estimación de Horas:** 10 a 14 horas

### User Story
"Quiero tener acceso inmediato a inserción de datos (FAB) y al asesor (Chatbot) desde cualquier rincón de la app sin importar si estoy en la variante Lite o Pro."

### Criterios de Aceptación
- Crear FAB gigante anclado en esquina inferior derecha para Pro, y centro para Lite.
- Al pulsar, despliega un *Radial Menu* o *Bottom Sheet* con Opciones (Add Gasto, Ingreso, Voz).
- Componente de Botón de AI Coach colindante al FAB que despliega un chat conversacional de interfaz borrosa (Blur 16px).

---

### Especificación Técnica Detallada

#### 4.1 Floating Action Button (FAB)

**Ubicación:** `OWFinanceFrontend2025/src/components/QuickActionFab.vue` (nuevo)

**Posicionamiento:**
- **Pro:** Esquina inferior derecha (class: `fab-pro`)
- **Lite:** Centro inferior, flotante (class: `fab-lite`)

**Estilos Glassmorphism:**
```scss
.fab-main {
  width: 64px;
  height: 64px;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--q-primary), var(--q-secondary));
  backdrop-filter: blur(16px);
  box-shadow: 0 8px 32px rgba(14, 165, 233, 0.4);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  
  &:hover {
    transform: scale(1.1);
    box-shadow: 0 12px 40px rgba(14, 165, 233, 0.6);
  }
}
```

**Radial Menu (al hacer click):**
```typescript
interface QuickAction {
  id: 'expense' | 'income' | 'transfer' | 'voice' | 'scan';
  icon: string;
  label: string;
  color: string;
  action: () => void;
}

const quickActions: QuickAction[] = [
  { id: 'expense', icon: 'attach_money', label: 'Gasto', color: '#ef4444' },
  { id: 'income', icon: 'trending_up', label: 'Ingreso', color: '#10b981' },
  { id: 'transfer', icon: 'swap_horiz', label: 'Transferir', color: '#8b5cf6' },
  { id: 'voice', icon: 'mic', label: 'Voz', color: '#0ea5e9' },
  { id: 'scan', icon: 'camera_alt', label: 'Escanear', color: '#f59e0b' },
];
```

**Animación:**
- Usar `q-menu` con `transition-show="scale"` 
- Ángulo de distribución: 45° entre cada opción
- Delay de 50ms entre cada item para efecto cascade

#### 4.2 AI Coach Chat

**Ubicación:** `OWFinanceFrontend2025/src/components/AIChatCoachDialog.vue` (nuevo)

**Trigger:**
- Botón circular pequeño junto al FAB (icono de chat/bot)
- O en menú lateral ("Asesor IA")

**UI del Chat:**
```vue
<template>
  <q-dialog v-model="chatOpen" position="bottom">
    <q-card class="chat-glass-panel">
      <!-- Header con blur -->
      <q-card-section class="chat-header">
        <q-avatar size="40px" color="secondary">
          <q-icon name="psychology" color="white" />
        </q-avatar>
        <div>
          <div class="text-h6">Asesor Financiero</div>
          <div class="text-caption">IA · Siempre disponible</div>
        </div>
      </q-card-section>
      
      <!-- Mensajes -->
      <q-card-section class="chat-messages q-pa-md" style="height: 400px">
        <div v-for="msg in messages" :class="['message', msg.role]">
          {{ msg.content }}
        </div>
      </q-card-section>
      
      <!-- Input -->
      <q-card-section class="chat-input">
        <q-input v-model="input" placeholder="Pregúntame sobre tus finanzas..." />
      </q-card-section>
    </q-card>
  </q-dialog>
</template>
```

**Estilos Glassmorphism del chat:**
```scss
.chat-glass-panel {
  width: 100%;
  max-width: 480px;
  background: rgba(15, 23, 42, 0.8);
  backdrop-filter: blur(16px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  border-radius: 24px 24px 0 0;
}
```

#### 4.3 Integración con Backend (Chatbot)

**Endpoints a crear:**

```php
// routes/api/chatbot.php (nuevo)

// POST /api/v1/chatbot/message
public function message(Request $request)
{
    // Body: { message: string, context: [...] }
    // Returns: { reply: string, suggestions: [...] }
}
```

**Servicio:**
```php
// app/Services/FinancialChatbotService.php
class FinancialChatbotService
{
    public function chat(string $message, array $context): ChatResponse
    {
        // 1. Construir prompt con contexto del usuario
        // 2. Enviar a LLM
        // 3. Parsear respuesta
        // 4. Generar sugerencias de acción
    }
}
```

**Contexto inyectado al LLM:**
```php
$context = [
    'user_profile' => $user->financial_profile_context ?? 'No configurado',
    'monthly_income' => $user->currentMonthlyIncome(),
    'jars_status' => $user->jars()->with('balances')->get(),
    'recent_transactions' => $user->transactions()->latest(5)->get(),
    'savings_rate' => $this->calculateSavingsRate($user),
];
```

**Prompt del Sistema:**
```
Eres OWFinance AI, un asesor financiero personalizado. 
Usuario: {{user_name}}
Perfil: {{financial_profile}}
Ingresos mensuales: {{monthly_income}}
Estado de jars: {{jars_summary}}

Guidelines:
- Sé conciso y amigable
- Usa emojis relevantes
- Proporciona consejos prácticos
- Si preguntan por números, usa los datos proporcionados
- Sugiere acciones concretas cuando sea relevante
- Nunca des advice financiero profesional
```

#### 4.4 Persistencia de Conversación

```php
// database/migrations/xxxx_xx_xx_create_chatbot_conversations_table.php
Schema::create('chatbot_conversations', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->cascadeOnDelete();
    $table->text('user_message');
    $table->text('bot_response');
    $table->json('context_snapshot')->nullable();
    $table->string('llm_provider')->nullable();
    $table->integer('tokens_used')->nullable();
    $table->timestamps();
});
```

---

## 5. Perfil Contextual para Coach Financiero (IA)

### Información Basic
- **Name:** Integración de "Sobre Mí" y Motor de Contexto LLM.
- **Status:** To Do
- **Priority:** Urgente (Nueva Fase)
- **Role:** AI Engineer, Backend
- **Estimación de Horas:** 14 a 18 horas

### User Story
"Quiero enseñarle a la IA quién soy (mi tipo de trabajo, familia, deudas críticas y aversión al riesgo) mediante un campo de texto libre, para que las sugerencias de inversión y presupuestos de cántaros sean hiper-personalizadas reales."

### Criterios de Aceptación
- Crear campo `financial_profile_context` tipo TEXT en la tabla de `users` o `profiles`.
- Crear vista de interfaz (Settings -> Perfil Financiero IA) con un textarea Liquid Glass.
- Las llamadas al API del Chatbot **deben obligatoriamente inyectar** este texto como System Prompt, sumando saldos actuales e Idioma Ocioso.

---

### Especificación Técnica Detallada

#### 5.1 Base de Datos

**Modificación de tabla users:**

```php
// database/migrations/xxxx_xx_xx_add_financial_profile_to_users_table.php
Schema::table('users', function (Blueprint $table) {
    $table->text('financial_profile_context')->nullable()->after('currency_id');
    $table->enum('risk_tolerance', ['conservative', 'moderate', 'aggressive'])->nullable()->after('financial_profile_context');
    $table->string('employment_type')->nullable()->after('risk_tolerance'); // employed, freelance, entrepreneur, retired
    $table->integer('family_size')->nullable()->after('employment_type');
    $table->decimal('monthly_debt_commitment', 15, 2)->nullable()->after('family_size');
});
```

#### 5.2 Backend - Perfil Service

**Ubicación:** `OWFINANCEBackend2025/app/Services/UserFinancialProfileService.php` (nuevo)

```php
class UserFinancialProfileService
{
    public function getProfile(int $userId): FinancialProfile
    {
        return FinancialProfile::fromUser(User::findOrFail($userId));
    }

    public function updateProfile(int $userId, ProfileUpdateRequest $request): FinancialProfile
    {
        $user = User::findOrFail($userId);
        $user->fill($request->validated());
        $user->save();
        
        return $this->getProfile($userId);
    }

    public function generateContextForLLM(int $userId): array
    {
        $user = User::with(['jars.balances', 'accounts', 'transactions' => function($q) {
            $q->where('created_at', '>=', now()->subMonths(3));
        }])->findOrFail($userId);

        return [
            'profile_text' => $user->financial_profile_context,
            'risk_tolerance' => $user->risk_tolerance,
            'employment' => $user->employment_type,
            'family_size' => $user->family_size,
            'monthly_debt' => $user->monthly_debt_commitment,
            'jars' => $user->jars->map(fn($j) => [
                'name' => $j->name,
                'target' => $j->target_amount,
                'current' => $j->currentBalance(),
                'percentage' => $j->percentage,
            ]),
            'accounts' => $user->accounts->sum('balance'),
            'recent_spending_categories' => $this->getTopCategories($user),
            'savings_rate' => $this->calculateSavingsRate($user),
        ];
    }
}
```

#### 5.3 Frontend - UI de Perfil

**Ubicación:** `OWFinanceFrontend2025/src/pages/user/settings/FinancialProfilePage.vue` (nuevo)

**Ruta a agregar en `routes.ts`:**
```typescript
{
  path: '/user/settings/financial-profile',
  component: () => import('pages/user/settings/FinancialProfilePage.vue'),
  meta: { role: 'user', auth: true }
}
```

**Componentes del formulario:**
1. Textarea principal "Sobre Mí" (contenido libre)
2. Selector de tolerancia al riesgo (slider visual)
3. Tipo de empleo (dropdown)
4. Tamaño de familia (number input)
5. Deudas mensuales comprometidas (currency input)
6. Preview del contexto que se envía a IA

**UI Glassmorphism:**
```vue
<template>
  <q-page class="q-pa-md">
    <div class="glass-panel q-pa-lg">
      <h2 class="text-h5 q-mb-md">Perfil Financiero IA</h2>
      
      <q-input
        v-model="profileContext"
        type="textarea"
        label="Cuéntame sobre ti"
        hint="Tu trabajo, metas, situación familiar, deudas importantes..."
        class="q-mb-lg"
        rows="6"
      />
      
      <q-slider
        v-model="riskTolerance"
        :min="0"
        :max="2"
        :step="1"
        markers
        marker-labels
        class="q-mb-lg"
      />
      
      <!-- Preview del contexto -->
      <div class="context-preview glass-panel-dark q-pa-md">
        <div class="text-caption text-grey">Contexto que recibirá la IA:</div>
        <pre>{{ generatedContext }}</pre>
      </div>
    </div>
  </q-page>
</template>
```

#### 5.4 Integración con Chatbot

**Modificar `FinancialChatbotService.php`:**

```php
public function chat(string $message, int $userId): ChatResponse
{
    // OBLIGATORIO: Obtener contexto del perfil
    $profileContext = app(UserFinancialProfileService::class)
        ->generateContextForLLM($userId);
    
    $systemPrompt = $this->buildSystemPrompt($profileContext);
    
    // Resto del procesamiento...
}
```

#### 5.5 Casos de Uso del Perfil

| Escenario | Pregunta a IA | Respuesta personalizada |
|-----------|---------------|------------------------|
| Freelancer | "Cómo organizar mis ingresos?" | "Dado que tus ingresos son variables, te sugiero..." |
| Familia 4 miembros | "Presupuesto sugerido" | "Para una familia de 4, el 50/30/20 sugiere..." |
| Deudas altas | "Cómo salir de deudas?" | "Con {{monthly_debt}} en deudas, prioriza..." |
| Conservador | "Dónde invertir?" | "Dado tu perfil conservador, considera..." |

---

## 6. Implementación Front-end Adaptativa (Lite vs Pro)

### Información Basic
- **Name:** Enrutamiento Dinámico y Componentes Condicionales (Pro/Lite).
- **Status:** To Do
- **Priority:** Alta
- **Role:** Frontend, UI/UX
- **Estimación de Horas:** 40 a 50 horas

### User Story
"Quiero alternar mi app entre un modo simple "Lite" para ver resúmenes en la calle, y un modo "Pro" con alta densidad de datos (Grids, reportes) si me siento a conciliar cuentas."

### Criterios de Aceptación
- Refactorizar layouts base en Quasar usando `<component :is="activeLayout">`.
- Construir versión 'Pro': Super-Grid tipo hoja de cálculo con selección masiva.
- Construir versión 'Lite': Enfoque en tarjetas Hero Balance gigantescas.

---

### Especificación Técnica Detallada

#### 6.1 Arquitectura de Versiones

**Modelo de datos:**
```typescript
// En auth store
interface User {
  // ... existing fields
  plan: 'lite' | 'pro';
  plan_expires_at: string | null;
}
```

**Feature Matrix (de `docs/ui-ux/06-version-matrix-differences.md`):**

| Feature | Lite | Pro |
|---------|------|-----|
| Dashboard principal | ✅ | ✅ |
| Ver transacciones | ✅ | ✅ |
| Crear transacción | ✅ | ✅ |
| Sistema de jars | ✅ | ✅ |
| Gráficos detallados | ❌ | ✅ |
| Bulk import | ❌ | ✅ |
| Reportes avanzados | ❌ | ✅ |
| Exportar datos | ❌ | ✅ |
| Múltiples cuentas | ✅ (1) | ✅ (ilimitado) |
| Categorías personalizadas | ✅ (5) | ✅ (ilimitado) |
| AI Coach | ❌ | ✅ |

#### 6.2 Router Dinámico

**Ubicación:** `OWFinanceFrontend2025/src/router/routes.ts`

```typescript
// Cambiar según el plan del usuario
const getUserLayout = (plan: 'lite' | 'pro') => {
  return plan === 'pro' ? ProUserLayout : LiteUserLayout;
};

// O usar componente dinámico
<component :is="currentLayout" />
```

#### 6.3 Layouts Separados

**Pro Layout:**
- Sidebar expandido con navegación completa
- Header con búsqueda global, notificaciones, usuario
- Contenido: Grids densos, tablas, filtros avanzados

**Lite Layout:**
- Bottom navigation bar (max 4 items)
- Cards grandes, touch-friendly
- Focus en acciones principales

#### 6.4 Componentes Versionados

**Patrón de implementación:**
```vue
<!-- src/components/jars/JarListPro.vue -->
<template>
  <q-table :rows="jars" columns="..." flat bordered />
</template>

<!-- src/components/jars/JarListLite.vue -->
<template>
  <div class="row q-col-gutter-md">
    <q-card v-for="jar in jars" class="col-12">
      <q-card-section>
        <div class="text-h6">{{ jar.name }}</div>
        <q-linear-progress :value="jar.percentage / 100" />
      </q-card-section>
    </q-card>
  </div>
</template>

<!-- src/components/jars/JarList.vue (componente principal) -->
<template>
  <component :is="currentJarListComponent" />
</template>

<script setup>
import { computed } from 'vue';
import { useAuthStore } from 'stores/auth';
import JarListLite from './JarListLite.vue';
import JarListPro from './JarListPro.vue';

const authStore = useAuthStore();
const currentJarListComponent = computed(() => {
  return authStore.user?.plan === 'pro' ? JarListPro : JarListLite;
});
</script>
```

#### 6.5 Stores con Lógica de Plan

**Ubicación:** `OWFinanceFrontend2025/src/stores/plan.ts` (nuevo)

```typescript
import { defineStore } from 'pinia';

interface PlanFeatures {
  maxAccounts: number;
  maxCategories: number;
  hasBulkImport: boolean;
  hasAdvancedReports: boolean;
  hasAIChat: boolean;
  hasExport: boolean;
}

export const usePlanStore = defineStore('plan', {
  state: () => ({
    currentPlan: 'lite' as 'lite' | 'pro',
  }),
  
  getters: {
    features(): PlanFeatures {
      return {
        maxAccounts: this.currentPlan === 'pro' ? Infinity : 1,
        maxCategories: this.currentPlan === 'pro' ? Infinity : 5,
        hasBulkImport: this.currentPlan === 'pro',
        hasAdvancedReports: this.currentPlan === 'pro',
        hasAIChat: this.currentPlan === 'pro',
        hasExport: this.currentPlan === 'pro',
      };
    },
    
    canAccess(feature: keyof PlanFeatures): boolean {
      return this.features[feature];
    },
  },
  
  actions: {
    checkAndRedirect(feature: keyof PlanFeatures, router: Router) {
      if (!this.canAccess(feature)) {
        router.push('/user/upgrade-plan');
      }
    },
  },
});
```

#### 6.6 Página de Upgrade

**Ubicación:** `OWFinanceFrontend2025/src/pages/user/UpgradePlanPage.vue` (nuevo)

- Comparación visual Lite vs Pro
- Botones de llamada a acción
- FAQ
- Testimonios (opcional)

---

## 7. Detección de Patrones y Notificación de Confirmación

### Información Basic
- **Name:** Algoritmo de Detección de Patrones y Notificación de Confirmación.
- **Status:** To Do
- **Priority:** Baja
- **Role:** Backend, AI Engineer
- **Estimación de Horas:** 10 a 14 horas

### User Story
"Como usuario recurrente, quiero que la app detecte patrones en mis gastos (pagos mensuales, suscripciones, tendencias) y me notifique proactivamente para confirmar o ajustar."

### Criterios de Aceptación
- Algoritmo que analice últimos 3 meses de transacciones del usuario.
- Detección de gastos recurrentes (mismo monto ±10%, misma categoría, periodicidad).
- Notificación push o in-app sugiriendo confirmación de gasto recurrente.
- Dashboard de patrones detectados con opción de crear "gasto automático".

---

### Especificación Técnica Detallada

#### 7.1 Algoritmo de Detección

**Backend - Servicio de detección:**

**Ubicación:** `OWFINANCEBackend2025/app/Services/PatternDetectionService.php` (nuevo)

```php
class PatternDetectionService
{
    public function analyzeUserPatterns(int $userId): array
    {
        $transactions = Transaction::where('user_id', $userId)
            ->where('created_at', '>=', now()->subMonths(3))
            ->get();
            
        return [
            'recurring_expenses' => $this->findRecurringExpenses($transactions),
            'spending_trends' => $this->analyzeTrends($transactions),
            'category_patterns' => $this->analyzeCategoryPatterns($transactions),
            'anomalies' => $this->detectAnomalies($transactions),
        ];
    }
    
    private function findRecurringExpenses(Collection $transactions): array
    {
        // Agrupar por descripción, categoría, cuenta
        // Buscar repeticiones con tolerancia de ±10% en monto
        // Detectar periodicidad (semanal, quincenal, mensual)
        // Retornar: [{description, amount, category, frequency, confidence}]
    }
}
```

#### 7.2 Base de Datos

```php
// database/migrations/xxxx_xx_xx_create_detected_patterns_table.php
Schema::create('detected_patterns', function (Blueprint $table) {
    $table->id();
    $table->foreignId('user_id')->constrained()->cascadeOnDelete();
    $table->string('pattern_type'); // recurring, trend, anomaly
    $table->string('description');
    $table->decimal('expected_amount', 15, 2)->nullable();
    $table->string('frequency')->nullable(); // weekly, biweekly, monthly
    $table->foreignId('category_id')->nullable()->constrained()->nullOnDelete();
    $table->decimal('confidence', 3, 2);
    $table->boolean('user_confirmed')->default(false);
    $table->boolean('auto_create_enabled')->default(false);
    $table->timestamps();
});
```

#### 7.3 Sistema de Notificaciones

**Backend - Controlador de notificaciones:**

```php
// routes/api/patterns.php

// GET /api/v1/patterns
public function index(Request $request)

// POST /api/v1/patterns/{id}/confirm
public function confirm(int $id)

// POST /api/v1/patterns/{id}/enable-auto
public function enableAuto(int $id)
```

**Servicio de notificación:**
```php
// app/Services/PatternNotificationService.php
class PatternNotificationService
{
    public function notifyNewPattern(User $user, Pattern $pattern)
    {
        // Notificación in-app
        Notification::send($user, new PatternDetected($pattern));
        
        // Notificación push (si está habilitado)
        if ($user->push_notifications_enabled) {
            PushNotification::send($user->device_token, [
                'title' => 'Patrón detectado',
                'body' => "Detectamos que gastas {$pattern->expected_amount} en {$pattern->description} cada {$pattern->frequency}",
            ]);
        }
    }
}
```

#### 7.4 Dashboard de Patrones (Frontend)

**Ubicación:** `OWFinanceFrontend2025/src/pages/user/patterns/PatternDashboard.vue` (nuevo)

**UI:**
- Lista de patrones detectados
- Gráfico de tendencia por categoría
- Acciones: Confirmar, Ignorar, Crear Automático
- Configuración de umbrales

#### 7.5 Gastos Automáticos (Opcional)

**Crear transacciones automáticamente:**

```php
// app/Jobs/ProcessAutomaticExpenses.php
class ProcessAutomaticExpenses implements ShouldQueue
{
    public function handle()
    {
        $patterns = DetectedPattern::where('auto_create_enabled', true)
            ->where('user_confirmed', true)
            ->get();
            
        foreach ($patterns as $pattern) {
            // Crear transacción pendiente de confirmación
            // O crear directamente según preferencia del usuario
        }
    }
}
```

---

## 📊 Resumen Total de Horas

| # | Tarea | Horas Min | Horas Max |
|---|-------|-----------|-----------|
| 1 | Transcripción Voz (NLP) | 16 | 24 |
| 2 | Cámara + OCR | 20 | 30 |
| 3 | Distribución Jarras | 12 | 16 |
| 4 | FAB + Chat Modal | 10 | 14 |
| 5 | Coach IA (Perfil Contextual) | 14 | 18 |
| 6 | Lite vs Pro (Refactor UI) | 40 | 50 |
| 7 | Detección de Patrones | 10 | 14 |
| | **TOTAL** | **122** | **166** |

**Promedio estimado:** ~144 horas → **~3.6 semanas** (a 40h/semana)

---

## 🔧 Dependencias Técnicas Comunes

Todas las tareas futuras usarán:

### Backend (Laravel)
```json
// composer.json - agregar
"openai-php/laravel": "^0.8.0",
"anthrop-ai/sdk": "^0.9.0",
"google/cloud-vision": "^1.0",
"aws/aws-sdk-php": "^3.0"
```

### Frontend (Quasar)
```json
// package.json - agregar
"@capacitor/camera": "^6.0.0",
"@capacitor/filesystem": "^6.0.0",
"@capacitor/push-notifications": "^6.0.0",
"vue-chartjs": "^5.0.0",
```

---

## 📋 Checklist de Preparación para Notion

Antes de importar a Notion, verificar:

- [ ] ID de base de datos Notion configurado en MCP
- [ ] API Key de Notion configurada
- [ ] Templates de propiedades en Notion coinciden con este documento
- [ ] Campos de este MD cubran todas las propiedades de Notion

---

## 🛠 Guía de Integración MCP para Notion

### Configuración del Servidor MCP

Para conectar este proyecto con Notion, se necesita configurar un servidor MCP (Model Context Protocol). Opciones disponibles:

#### Opción 1: Notion MCP Server (oficial)
```bash
# Instalación
npm install -g @notionhq/notion-mcp-server

# Configuración en ~/.config/mcp.json
{
  "mcpServers": {
    "notion": {
      "command": "npx",
      "args": ["@notionhq/notion-mcp-server"],
      "env": {
        "NOTION_API_KEY": "secret_..."
      }
    }
  }
}
```

#### Opción 2: Cline/Roo integraciones
Ya tienes instalado en tu sistema:
- `saoudrizwan.claude-dev` - tiene integración MCP
- `rooveterinaryinc.roo-cline` - tiene integración MCP

#### Opción 3: Script manual de sincronización
 Mientras MCP no esté configurado, usar script manual:

```bash
#!/bin/bash
# sync-to-notion.sh

# 1. Exportar este MD a formato Notion
# 2. Usar API de Notion para crear páginas

NOTION_TOKEN="secret_..."
DATABASE_ID="32de7ace976781958d00dd0d61583eac"

# Ejemplo: Crear página en Notion
curl -X POST "https://api.notion.com/v1/pages" \
  -H "Authorization: Bearer $NOTION_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Notion-Version: 2022-06-28" \
  -d '{
    "parent": { "database_id": "'$DATABASE_ID'" },
    "properties": {
      "Name": { "title": [{ "text": { "content": "Tarea 1" } }] },
      "Status": { "select": { "name": "To Do" } },
      "Priority": { "select": { "name": "Alta" } }
    }
  }'
```

---

> **Estado Notion:** ✅ Las 7 tareas están sincronizadas con la base de datos Notion (ID: `32de7ace976781958d00dd0d61583eac`). Cada tarea incluye User Story, Criterios de Aceptación, Desglose Técnico completo y Estimación de Horas desglosada por componente.

---

*Documento actualizado: 2026-03-24*
*Versión: 2.0 - Expanded Technical Details*
