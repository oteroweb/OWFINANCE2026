# TECH-002 — Tests Frontend (Vitest + Playwright)

**Tipo**: Trabajo técnico (IA puede ejecutar)
**Prioridad**: Media-alta (requerido para staging production-ready)
**Tiempo estimado IA**: 3-4 horas

## Contexto

Frontend tiene ZERO tests. `package.json` tiene:
```json
"test": "echo \"No test specified\" && exit 0"
```

## Qué instalar

```bash
# Vitest (unit/integration)
npm install -D vitest @vue/test-utils @vitejs/plugin-vue happy-dom

# Playwright (E2E)
npm install -D @playwright/test
npx playwright install chromium
```

## Qué configurar

1. `vitest.config.ts` — configurar con happy-dom
2. `playwright.config.ts` — apuntar a http://localhost:9000 (quasar dev)
3. Actualizar `package.json` scripts:
   ```json
   "test:unit": "vitest",
   "test:e2e": "playwright test",
   "test": "vitest run"
   ```

## Tests prioritarios a escribir

### Unit tests (Vitest)
1. `useAiExtraction.test.ts` — mock axios, verificar retry logic, error mapping
2. `useAiChat.test.ts` — mock fetch SSE, verificar streaming, retry
3. `useImageCompressor.test.ts` — mock canvas API, verificar compresión
4. `useVoiceInput.test.ts` — mock SpeechRecognition, verificar start/stop

### Component tests (Vitest + @vue/test-utils)
1. `AutoIaDialog.test.ts` — render, chip clicks, submit
2. `AsesorPage.test.ts` — render empty state, suggestions, send message

### E2E tests (Playwright)
1. Login flow
2. Crear transacción manual
3. Auto IA dialog — escribir texto → confirmar extracción
4. Asesor IA — navegar, enviar mensaje

## Convenciones
- Tests en `src/__tests__/` para unit
- E2E en `e2e/` en raíz del proyecto
