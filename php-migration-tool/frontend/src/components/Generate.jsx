import { useState } from 'react'
import axios from 'axios'

export default function Generate({ uploadId, analysis, onGenerateComplete }) {
  const [generating, setGenerating] = useState(false)
  const [error, setError] = useState(null)

  const handleGenerate = async () => {
    setGenerating(true)
    setError(null)

    try {
      const response = await axios.post(
        `/api/generate/${uploadId}`,
        { analysis, options: {} }
      )
      onGenerateComplete(response.data)
    } catch (err) {
      setError(err.response?.data?.detail || 'Generation failed')
      setGenerating(false)
    }
  }

  if (generating) {
    return (
      <div className="text-center py-12">
        <div className="text-6xl mb-6 animate-bounce">⚙️</div>
        <h2 className="text-2xl font-bold text-gray-800 mb-4">
          Generating Python Code...
        </h2>
        <p className="text-gray-600 mb-8">
          Creating FastAPI endpoints, Pydantic models, and tests
        </p>
        <div className="max-w-md mx-auto space-y-3">
          {['OpenAPI Specification', 'FastAPI Routes', 'Pydantic Models', 'Test Suite'].map(
            (item, index) => (
              <div
                key={index}
                className="flex items-center justify-between bg-gray-100 rounded-lg p-3"
                style={{ animationDelay: `${index * 0.2}s` }}
              >
                <span className="text-gray-700">{item}</span>
                <span className="text-green-500 animate-pulse">✓</span>
              </div>
            )
          )}
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="text-center py-12">
        <div className="text-6xl mb-6">❌</div>
        <h2 className="text-2xl font-bold text-red-600 mb-4">
          Generation Failed
        </h2>
        <p className="text-gray-600 mb-8">{error}</p>
        <button
          onClick={handleGenerate}
          className="px-6 py-3 bg-purple-600 text-white rounded-lg hover:bg-purple-700"
        >
          Try Again
        </button>
      </div>
    )
  }

  return (
    <div className="text-center">
      <div className="mb-8">
        <div className="text-6xl mb-4">🐍</div>
        <h2 className="text-3xl font-bold text-gray-800 mb-4">
          Ready to Generate Python Code
        </h2>
        <p className="text-gray-600">
          We'll create a complete FastAPI project with:
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4 max-w-2xl mx-auto mb-8">
        {[
          { icon: '📝', title: 'OpenAPI Spec', desc: 'Contract-first API definition' },
          { icon: '🚀', title: 'FastAPI Code', desc: 'Modern Python endpoints' },
          { icon: '📦', title: 'Pydantic Models', desc: 'Type-safe data models' },
          { icon: '✅', title: 'Test Suite', desc: 'Automated tests with pytest' },
        ].map((item, index) => (
          <div
            key={index}
            className="bg-gradient-to-br from-purple-50 to-blue-50 rounded-xl p-6 text-left"
          >
            <div className="text-3xl mb-2">{item.icon}</div>
            <h3 className="font-bold text-gray-800 mb-1">{item.title}</h3>
            <p className="text-sm text-gray-600">{item.desc}</p>
          </div>
        ))}
      </div>

      <button
        onClick={handleGenerate}
        className="px-8 py-4 bg-gradient-to-r from-purple-600 to-blue-600 text-white rounded-xl font-bold text-lg hover:shadow-xl hover:scale-105 transition-all"
      >
        Generate Python Code 🚀
      </button>
    </div>
  )
}
