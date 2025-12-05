import { useState, useEffect } from 'react'
import axios from 'axios'

export default function Analysis({ uploadId, onAnalysisComplete }) {
  const [analyzing, setAnalyzing] = useState(false)
  const [analysis, setAnalysis] = useState(null)
  const [error, setError] = useState(null)

  useEffect(() => {
    if (uploadId && !analysis) {
      handleAnalyze()
    }
  }, [uploadId])

  const handleAnalyze = async () => {
    setAnalyzing(true)
    setError(null)

    try {
      const response = await axios.post(
        `/api/analyze/${uploadId}`
      )
      setAnalysis(response.data)
    } catch (err) {
      setError(err.response?.data?.detail || 'Analysis failed')
    } finally {
      setAnalyzing(false)
    }
  }

  const handleContinue = () => {
    onAnalysisComplete(analysis)
  }

  if (analyzing) {
    return (
      <div className="text-center py-12">
        <div className="text-6xl mb-6 animate-pulse">🔍</div>
        <h2 className="text-2xl font-bold text-gray-800 mb-4">
          Analyzing Your PHP Project...
        </h2>
        <p className="text-gray-600">
          Extracting routes, models, and business logic
        </p>
        <div className="mt-8">
          <div className="w-64 h-2 bg-gray-200 rounded-full mx-auto overflow-hidden">
            <div className="h-full bg-gradient-to-r from-purple-600 to-blue-600 animate-pulse" />
          </div>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="text-center py-12">
        <div className="text-6xl mb-6">❌</div>
        <h2 className="text-2xl font-bold text-red-600 mb-4">Analysis Failed</h2>
        <p className="text-gray-600 mb-8">{error}</p>
        <button
          onClick={handleAnalyze}
          className="px-6 py-3 bg-purple-600 text-white rounded-lg hover:bg-purple-700"
        >
          Try Again
        </button>
      </div>
    )
  }

  if (!analysis) {
    return null
  }

  return (
    <div>
      <div className="text-center mb-8">
        <div className="text-6xl mb-4">✅</div>
        <h2 className="text-3xl font-bold text-gray-800 mb-2">
          Analysis Complete!
        </h2>
        <p className="text-gray-600">{analysis.summary}</p>
      </div>

      {/* Analysis Results */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        {/* Routes Card */}
        <div className="bg-gradient-to-br from-purple-50 to-purple-100 rounded-xl p-6">
          <div className="text-4xl mb-3">🛣️</div>
          <h3 className="text-2xl font-bold text-purple-900 mb-2">
            {analysis.routes.length}
          </h3>
          <p className="text-purple-700 font-medium">API Routes Found</p>
        </div>

        {/* Models Card */}
        <div className="bg-gradient-to-br from-blue-50 to-blue-100 rounded-xl p-6">
          <div className="text-4xl mb-3">📦</div>
          <h3 className="text-2xl font-bold text-blue-900 mb-2">
            {analysis.models.length}
          </h3>
          <p className="text-blue-700 font-medium">Models/Classes</p>
        </div>

        {/* Files Card */}
        <div className="bg-gradient-to-br from-green-50 to-green-100 rounded-xl p-6">
          <div className="text-4xl mb-3">📄</div>
          <h3 className="text-2xl font-bold text-green-900 mb-2">
            {analysis.file_count}
          </h3>
          <p className="text-green-700 font-medium">PHP Files</p>
        </div>
      </div>

      {/* Routes List */}
      {analysis.routes.length > 0 && (
        <div className="mb-8">
          <h3 className="text-xl font-bold text-gray-800 mb-4">
            📍 Discovered Routes
          </h3>
          <div className="bg-gray-50 rounded-xl p-4 max-h-64 overflow-y-auto">
            {analysis.routes.map((route, index) => (
              <div
                key={index}
                className="flex items-center justify-between py-2 border-b border-gray-200 last:border-0"
              >
                <div className="flex items-center">
                  <span
                    className={`px-3 py-1 rounded-full text-xs font-bold mr-3 ${
                      route.method === 'GET'
                        ? 'bg-green-100 text-green-700'
                        : route.method === 'POST'
                        ? 'bg-blue-100 text-blue-700'
                        : route.method === 'PUT'
                        ? 'bg-yellow-100 text-yellow-700'
                        : 'bg-red-100 text-red-700'
                    }`}
                  >
                    {route.method}
                  </span>
                  <code className="text-sm font-mono text-gray-700">
                    {route.path}
                  </code>
                </div>
                <span className="text-xs text-gray-500">{route.file}</span>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Continue Button */}
      <div className="text-center">
        <button
          onClick={handleContinue}
          className="px-8 py-4 bg-gradient-to-r from-purple-600 to-blue-600 text-white rounded-xl font-bold text-lg hover:shadow-xl hover:scale-105 transition-all"
        >
          Continue to Generation →
        </button>
      </div>
    </div>
  )
}
