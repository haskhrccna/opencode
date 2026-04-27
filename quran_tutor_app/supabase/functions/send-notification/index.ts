import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

const ONE_SIGNAL_API_KEY = Deno.env.get('ONESIGNAL_API_KEY')
const ONE_SIGNAL_APP_ID = Deno.env.get('ONESIGNAL_APP_ID')

interface NotificationPayload {
  include_external_user_ids?: string[]
  filters?: Array<{ field: string; key: string; relation: string; value: string }>
  headings: { en: string }
  contents: { en: string }
  data?: Record<string, unknown>
}

serve(async (req) => {
  try {
    // Verify request has valid auth
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response('Unauthorized', { status: 401 })
    }

    const payload: NotificationPayload = await req.json()

    // Build OneSignal request
    const oneSignalPayload = {
      app_id: ONE_SIGNAL_APP_ID,
      ...payload,
    }

    // Send to OneSignal REST API
    const response = await fetch('https://onesignal.com/api/v1/notifications', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${ONE_SIGNAL_API_KEY}`,
      },
      body: JSON.stringify(oneSignalPayload),
    })

    if (!response.ok) {
      const error = await response.text()
      console.error('OneSignal API error:', error)
      return new Response(`OneSignal error: ${error}`, { status: 500 })
    }

    const result = await response.json()
    return new Response(JSON.stringify(result), {
      headers: { 'Content-Type': 'application/json' },
    })
  } catch (error) {
    console.error('Function error:', error)
    return new Response(`Error: ${error.message}`, { status: 500 })
  }
})
