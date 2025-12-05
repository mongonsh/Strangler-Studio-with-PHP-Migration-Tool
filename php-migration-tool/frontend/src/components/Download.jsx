import { useState } from 'react'

export default function Download({ generated }) {
  const [selectedFile, setSelectedFile] = useState(null)
  const [fileContent, setFileContent] = useState(null)

  const handlePreview = async (filename) => {
    setSelectedFile(filename)
    
    try {
      const response = await fetch(
        `/api/preview/${generated.output_id}/${filename}`
      )
      const data = await response.json()
      setFileContent(data.content)
    } catch (err) {
      console.error('Preview failed:', err)
    }
  }

  const handleDownload = () => {
    window.open(
      `/api/download/${generated.output_id}`,
      '_blank'
    )
  }

  return (
    <div>
      <div className="text-center mb-8">
        <div className="text-6xl mb-4">🎉</div>
        <h2 className="text-3xl font-bold text-gray-800 mb-2">
          Migration Complete!
        </h2>
        <p className="text-gray-600">
          Your Python/FastAPI project is ready to download
        </p>
      </div>

      {/* Generated Files */}
      <div className="mb-8">
        <h3 className="text-xl font-bold text-gray-800 mb-4">
          📁 Generated Files
        </h3>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
          {Object.entries(generated.files).map(([key, filename]) => (
            <button
              key={key}
              onClick={() => handlePreview(filename)}
              className={`p-4 rounded-lg text-left transition-all ${
                selectedFile === filename
                  ? 'bg-purple-100 border-2 border-purple-500'
                  : 'bg-gray-50 hover:bg-gray-100 border-2 border-transparent'
              }`}
            >
              <div className="flex items-center justify-between">
                <div className="flex items-center">
                  <span className="text-2xl mr-3">
                    {filename.endsWith('.py')
                      ? '🐍'
                      : filename.endsWith('.yaml')
                      ? '📋'
                      : filename.endsWith('.md')
                      ? '📝'
                      : '📄'}
                  </span>
                  <div>
                    <p className="font-medium text-gray-800">{filename}</p>
                    <p className="text-xs text-gray-500 capitalize">{key}</p>
                  </div>
                </div>
                <span className="text-purple-600">→</span>
              </div>
            </button>
          ))}
        </div>
      </div>

      {/* File Preview */}
      {fileContent && (
        <div className="mb-8">
          <h3 className="text-xl font-bold text-gray-800 mb-4">
            👁️ Preview: {selectedFile}
          </h3>
          <div className="bg-gray-900 rounded-xl p-6 overflow-x-auto">
            <pre className="text-sm text-green-400 font-mono">
              <code>{fileContent}</code>
            </pre>
          </div>
        </div>
      )}

      {/* Download Button */}
      <div className="text-center">
        <button
          onClick={handleDownload}
          className="px-8 py-4 bg-gradient-to-r from-green-600 to-emerald-600 text-white rounded-xl font-bold text-lg hover:shadow-xl hover:scale-105 transition-all"
        >
          📥 Download Complete Project
        </button>
        
        <div className="mt-6 p-4 bg-blue-50 rounded-lg">
          <p className="text-sm text-blue-800">
            <strong>Next Steps:</strong> Extract the ZIP, run{' '}
            <code className="bg-blue-100 px-2 py-1 rounded">pip install -r requirements.txt</code>
            , then{' '}
            <code className="bg-blue-100 px-2 py-1 rounded">uvicorn main:app --reload</code>
          </p>
        </div>
      </div>
    </div>
  )
}
