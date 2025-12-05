"""
Vercel Serverless Function Entry Point
"""
from main import app

# Vercel expects a handler
handler = app
