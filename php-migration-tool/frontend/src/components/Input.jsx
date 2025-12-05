import { useState } from 'react'
import axios from 'axios'

export default function Input({ onInputComplete }) {
  const [mode, setMode] = useState('github') // 'github' or 'zip'
  const [githubUrl, setGithubUrl] = useState('')
  const [branch, setBranch] = useState('main')
  const [previewPort, setPreviewPort] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)
  const [previewStatus, setPreviewStatus] = useState(null)

  const handleGithubSubmit = async () => {
    if (!githubUrl) return

    setLoading(true)
    setError(null)

    try {
      const response = await axios.post('/api/clone-github', {
        repo_url: githubUrl,
        branch: branch || 'main',
      })

      onInputComplete(response.data.upload_id)
    } catch (err) {
      setError(err.response?.data?.detail || 'Failed to clone repository')
    } finally {
      setLoading(false)
    }
  }

  const handlePreviewCheck = async () => {
    if (!previewPort) return

    try {
      const response = await axios.post('/api/check-php-server', {
        port: parseInt(previewPort),
        project_id: 'preview',
      })

      setPreviewStatus(response.data)
    } catch (err) {
      setPreviewStatus({ accessible: false, error: 'Failed to check server' })
    }
  }

  return (
    <div className="space-y-8">
      {/* Title */}
      <div className="text-center mb-8">
        <h2
          className="text-4xl mb-4"
          style={{
            fontFamily: 'var(--font-title)',
            fontWeight: 700,
            color: 'var(--color-bone)',
            letterSpacing: '0.05em',
          }}
        >
          SPECIMEN ACQUISITION
        </h2>
        <p
          style={{
            fontFamily: 'var(--font-body)',
            color: 'var(--color-lightning)',
            fontSize: '1.125rem',
            fontStyle: 'italic',
          }}
        >
          Provide the source material for reanimation
        </p>
      </div>

      {/* Mode Selector */}
      <div className="flex gap-4 justify-center mb-8">
        <button
          onClick={() => setMode('github')}
          className={`btn-laboratory ${mode !== 'github' ? 'opacity-50' : ''}`}
        >
          GitHub Repository
        </button>
        <button
          onClick={() => setMode('zip')}
          className={`btn-laboratory ${mode !== 'zip' ? 'opacity-50' : ''}`}
          disabled
        >
          ZIP Upload (Coming Soon)
        </button>
      </div>

      {/* GitHub Input */}
      {mode === 'github' && (
        <div className="space-y-6 max-w-3xl mx-auto">
          {/* Repository URL */}
          <div>
            <label
              className="block mb-2 text-sm uppercase tracking-wider"
              style={{
                fontFamily: 'var(--font-title)',
                color: 'var(--color-electric-blue)',
              }}
            >
              Repository URL
            </label>
            <input
              type="text"
              value={githubUrl}
              onChange={(e) => setGithubUrl(e.target.value)}
              placeholder="https://github.com/username/repository"
              className="input-laboratory"
            />
          </div>

          {/* Branch */}
          <div>
            <label
              className="block mb-2 text-sm uppercase tracking-wider"
              style={{
                fontFamily: 'var(--font-title)',
                color: 'var(--color-electric-blue)',
              }}
            >
              Branch
            </label>
            <input
              type="text"
              value={branch}
              onChange={(e) => setBranch(e.target.value)}
              placeholder="main"
              className="input-laboratory"
            />
          </div>

          {/* PHP Preview Port */}
          <div className="lab-panel">
            <label
              className="block mb-3 text-sm uppercase tracking-wider"
              style={{
                fontFamily: 'var(--font-title)',
                color: 'var(--color-toxic-green)',
              }}
            >
              Live PHP Preview (Optional)
            </label>
            <p
              className="mb-4 text-sm"
              style={{
                fontFamily: 'var(--font-body)',
                color: 'rgba(245, 245, 245, 0.6)',
                fontStyle: 'italic',
              }}
            >
              If your PHP project is running locally, enter the port to preview it
            </p>
            <div className="flex gap-3">
              <input
                type="number"
                value={previewPort}
                onChange={(e) => setPreviewPort(e.target.value)}
                placeholder="8080"
                className="input-laboratory flex-1"
              />
              <button
                onClick={handlePreviewCheck}
                className="btn-laboratory"
                disabled={!previewPort}
              >
                Test Connection
              </button>
            </div>

            {/* Preview Status */}
            {previewStatus && (
              <div
                className="mt-4 p-4 rounded"
                style={{
                  background: previewStatus.accessible
                    ? 'rgba(118, 255, 3, 0.1)'
                    : 'rgba(183, 28, 28, 0.1)',
                  border: `1px solid ${
                    previewStatus.accessible ? 'var(--color-toxic-green)' : 'var(--color-blood)'
                  }`,
                }}
              >
                <p
                  style={{
                    fontFamily: 'var(--font-body)',
                    color: previewStatus.accessible
                      ? 'var(--color-toxic-green)'
                      : 'var(--color-blood)',
                  }}
                >
                  {previewStatus.accessible
                    ? `Server accessible at localhost:${previewStatus.port}`
                    : `Cannot connect to localhost:${previewStatus.port}`}
                </p>
                {previewStatus.accessible && (
                  <iframe
                    src={`http://localhost:${previewStatus.port}`}
                    className="w-full h-96 mt-4 rounded"
                    style={{
                      border: '1px solid var(--color-electric-blue)',
                      background: '#fff',
                    }}
                    title="PHP Preview"
                  />
                )}
              </div>
            )}
          </div>

          {/* Error Message */}
          {error && (
            <div
              className="p-4 rounded"
              style={{
                background: 'rgba(183, 28, 28, 0.1)',
                border: '1px solid var(--color-blood)',
              }}
            >
              <p style={{ fontFamily: 'var(--font-body)', color: 'var(--color-blood)' }}>
                {error}
              </p>
            </div>
          )}

          {/* Submit Button */}
          <div className="text-center pt-6">
            <button
              onClick={handleGithubSubmit}
              disabled={!githubUrl || loading}
              className="btn-laboratory text-lg px-12 py-4"
            >
              {loading ? (
                <span className="flex items-center gap-3">
                  <span className="charging" style={{ width: '100px' }}></span>
                  Acquiring Specimen...
                </span>
              ) : (
                'Begin Experiment'
              )}
            </button>
          </div>
        </div>
      )}

      {/* Laboratory Notes */}
      <div
        className="mt-12 p-6 rounded"
        style={{
          background: 'rgba(26, 26, 26, 0.5)',
          border: '1px solid rgba(0, 212, 255, 0.1)',
        }}
      >
        <h3
          className="text-sm uppercase tracking-wider mb-3"
          style={{
            fontFamily: 'var(--font-title)',
            color: 'var(--color-brass)',
          }}
        >
          Laboratory Notes
        </h3>
        <ul
          className="space-y-2 text-sm"
          style={{
            fontFamily: 'var(--font-body)',
            color: 'rgba(245, 245, 245, 0.6)',
          }}
        >
          <li>• Public GitHub repositories are supported</li>
          <li>• Private repositories require authentication (coming soon)</li>
          <li>• PHP preview requires the project running on localhost</li>
          <li>• Supported frameworks: Laravel, Symfony, Slim, Plain PHP</li>
        </ul>
      </div>
    </div>
  )
}
