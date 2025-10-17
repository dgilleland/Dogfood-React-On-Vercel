# Deploying GitHub SSO (NextAuth) to Vercel

This document describes the exact environment variables and GitHub OAuth App settings required to run the NextAuth GitHub SSO integration in production on Vercel.

Prerequisites
- You have the NextAuth integration added to the app (see `pages/api/auth/[...nextauth].js`).
- You have a Vercel project for this repository and admin access to the Vercel dashboard.
- You can edit a GitHub OAuth App (Owner or Developer access on the GitHub account where the OAuth app was created).

1) Create / update your GitHub OAuth App

- URL: https://github.com/settings/developers -> OAuth Apps -> Your App
- Set Homepage URL to your production site (example):

  https://your-production-domain

- Add Authorization callback URL (exact):

  https://your-production-domain/api/auth/callback/github

- Keep a local callback URL for development if you want to continue testing locally:

  http://localhost:3000/api/auth/callback/github

- Save and copy the Client ID and Client Secret.

2) Add environment variables in Vercel

Go to your Vercel Project → Settings → Environment Variables and add the following (set to Target: Production; add to Preview if you want preview deployments to authenticate):

- `GITHUB_ID` = <Client ID from GitHub>
- `GITHUB_SECRET` = <Client Secret from GitHub>
- `NEXTAUTH_URL` = https://your-production-domain
- `NEXTAUTH_SECRET` = <a long random string; 32+ bytes recommended>

Notes on generation of `NEXTAUTH_SECRET`:
- PowerShell (Windows):

  [System.Convert]::ToBase64String((New-Object Security.Cryptography.RNGCryptoServiceProvider).GetBytes(32))

- Or on Unix/macOS: `openssl rand -base64 32`

3) (Optional) Database adapter

If you add a database adapter (Prisma, TypeORM, etc.) add `DATABASE_URL` (and any other adapter env vars) in Vercel. Re-deploy after adding.

4) Redeploy and test

- After saving env vars, redeploy the project on Vercel (Vercel usually redeploys automatically when env vars are added).
- Visit `https://your-production-domain` and click "Sign in with GitHub". You should be redirected to GitHub and back to your app.

5) Troubleshooting

- client_id is required — `GITHUB_ID` not present in the running environment.
- redirect_uri_mismatch — callback URL registered on GitHub doesn’t match the one used by the app. Ensure the callback above is present in the OAuth app.
- NO_SECRET / NEXTAUTH_URL warnings — make sure `NEXTAUTH_SECRET` and `NEXTAUTH_URL` are set in Vercel.

6) Optional: restrict to GitHub org members

- If you want to allow only users in a specific GitHub org, update the provider scopes to request `read:org`, and add a `signIn` callback in NextAuth that checks org membership using the access token. This requires adding `scope: 'read:user user:email read:org'` or similar to the provider config and logic to call GitHub's org membership endpoint.

7) Example checklist

- [ ] Add production callback URL on GitHub: `https://your-production-domain/api/auth/callback/github`
- [ ] Set `GITHUB_ID` and `GITHUB_SECRET` in Vercel
- [ ] Set `NEXTAUTH_URL` to `https://your-production-domain` in Vercel
- [ ] Set `NEXTAUTH_SECRET` to a random string in Vercel
- [ ] Redeploy and test sign-in

If you'd like, I can add a `signIn` callback example in `pages/api/auth/[...nextauth].js` to restrict sign-ins to a GitHub org, or help you wire a database adapter for persistent users. Tell me which next step you prefer.

Local testing helper (ngrok)
--------------------------------

This repo includes a small PowerShell helper to start ngrok and the Next.js dev server on Windows. It requires `ngrok` to be installed and available on your PATH.

Commands:

  npm run dev:ngrok

What it does:
- Starts `ngrok http 3000` and the Next dev server.
- Copy the HTTPS ngrok forwarding URL and add it as an Authorization callback URL in your GitHub OAuth App (e.g. `https://abcd1234.ngrok.io/api/auth/callback/github`).

If you prefer not to use the script, run these commands manually in separate shells:

PowerShell:

  ngrok http 3000
  npm run dev

