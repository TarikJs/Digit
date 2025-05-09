import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { corsHeaders } from '../_shared/cors.ts'

interface EmailPayload {
  to: string
  firstName: string
}

// Simple in-memory rate limiting (resets on function cold start)
const emailAttempts = new Map<string, { count: number; lastAttempt: number }>()
const RATE_LIMIT_WINDOW = 3600000 // 1 hour in milliseconds
const MAX_ATTEMPTS = 5 // Maximum emails per hour per address

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Get the request body
    const payload: EmailPayload = await req.json()
    const { to, firstName } = payload

    // Validate email format
    const emailRegex = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/
    if (!emailRegex.test(to)) {
      throw new Error('Invalid email format')
    }

    // Check rate limiting
    const now = Date.now()
    const userAttempts = emailAttempts.get(to) || { count: 0, lastAttempt: 0 }

    // Reset count if outside window
    if (now - userAttempts.lastAttempt > RATE_LIMIT_WINDOW) {
      userAttempts.count = 0
    }

    if (userAttempts.count >= MAX_ATTEMPTS) {
      throw new Error('Rate limit exceeded. Please try again later.')
    }

    // Update rate limiting info
    emailAttempts.set(to, {
      count: userAttempts.count + 1,
      lastAttempt: now,
    })

    // Simple confirmation email with minimal HTML to avoid spam filters
    const emailContent = `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Welcome to Digit</title>
      </head>
      <body style="
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
        line-height: 1.6;
        color: #1a1a1a;
        margin: 0;
        padding: 0;
        background-color: #f9fafb;
      ">
        <div style="
          max-width: 600px;
          margin: 0 auto;
          padding: 40px 20px;
          background-color: #ffffff;
          border-radius: 8px;
          box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        ">
          <div style="text-align: center; margin-bottom: 32px;">
            <img src="https://your-app-logo-url.com/logo.png" 
                 alt="Digit Logo" 
                 style="width: 80px; height: 80px; border-radius: 16px;"
            >
          </div>

          <h1 style="
            color: #4F46E5;
            font-size: 24px;
            font-weight: 600;
            text-align: center;
            margin-bottom: 24px;
          ">Welcome to Digit!</h1>

          <p style="
            color: #374151;
            font-size: 16px;
            margin-bottom: 24px;
            text-align: center;
          ">
            Hi ${firstName}
          </p>

          <p style="
            color: #374151;
            font-size: 16px;
            margin-bottom: 32px;
            text-align: center;
          ">
            We're excited to help you build better habits and achieve your goals.
          </p>

          <div style="text-align: center;">
            <a href="{{ .ConfirmationURL }}" 
               style="
                 display: inline-block;
                 background-color: #4F46E5;
                 color: #ffffff;
                 padding: 12px 24px;
                 border-radius: 6px;
                 text-decoration: none;
                 font-weight: 500;
                 margin-bottom: 32px;
               "
            >
              Confirm your email
            </a>
          </div>

          <div style="
            text-align: center;
            color: #6B7280;
            font-size: 14px;
            border-top: 1px solid #e5e7eb;
            padding-top: 24px;
          ">
            <p style="margin-bottom: 12px;">
              If you didn't create an account with Digit, you can safely ignore this email.
            </p>
            <p style="margin: 0;">
              © ${new Date().getFullYear()} Digit. All rights reserved.
            </p>
          </div>
        </div>
      </body>
      </html>
    `

    // Use Supabase's built-in email service
    const response = await fetch('https://api.supabase.co/v1/auth/send-email', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'apikey': Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      },
      body: JSON.stringify({
        email: to,
        type: 'signup',
        data: {
          subject: 'Welcome to Digit - Please Confirm Your Email',
          content: emailContent,
        }
      }),
    })

    if (!response.ok) {
      const error = await response.text()
      console.error('Email service error:', error)
      throw new Error(`Failed to send email: ${error}`)
    }

    const result = await response.json()
    console.log('Email sent successfully:', result)

    return new Response(JSON.stringify({ success: true }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })
  } catch (error) {
    console.error('Error in send-email function:', error)
    
    // Return appropriate error message
    const errorMessage = error.message.includes('Rate limit exceeded')
      ? { error: 'Too many email attempts. Please try again later.' }
      : { error: 'Failed to send email. Please try again.' }

    return new Response(JSON.stringify(errorMessage), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 429, // Rate limit status code
    })
  }
}) 