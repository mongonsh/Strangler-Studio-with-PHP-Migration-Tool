import { useState } from 'react'
import axios from 'axios'

export default function Upload({ onUploadComplete }) {
  const [file, setFile] = useState(null)
  const [uploading, setUploading] = useState(false)
  const [error, setError] = useState(null)

  const handleFileChange = (e) => {
    const selectedFile = e.target.files[0]
    if (selectedFile && selectedFile.name.endsWith('.zip')) {
      setFile(selectedFile)
      setError(null)
    } else {
      setError('Please select a ZIP file')
      setFile(null)
    }
  }

  const handleUpload = async () => {
    if (!file) return

    setUploading(true)
    setError(null)

    const formData = new FormData()
    formData.append('file', file)

    try {
      const response = await axios.post('/api/upload', formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      })

      onUploadComplete(response.data.upload_id)
    } catch (err) {
      setError(err.response?.data?.detail || 'Upload failed')
    } finally {
      setUploading(false)
    }
  }

  return (
    <div className="text-center">
      <div className="mb-8">
        <h2 className="text-3xl font-bold text-gray-800 mb-4">
          Upload Your PHP Project
        </h2>
        <p className="text-gray-600">
          Upload a ZIP file containing your PHP project for analysis
        </p>
      </div>

      <div className="max-w-xl mx-auto">
        {/* Drag & Drop Zone */}
        <div className="border-4 border-dashed border-gray-300 rounded-xl p-12 hover:border-purple-500 transition-colors">
          <div className="text-6xl mb-4">📦</div>
          
          <label className="cursor-pointer">
            <span className="text-lg font-medium text-purple-600 hover:text-purple-700">
              Choose a ZIP file
            </span>
            <input
              type="file"
              accept=".zip"
              onChange={handleFileChange}
              className="hidden"
            />
          </label>
          
          <p className="text-sm text-gray-500 mt-2">or drag and drop</p>
        </div>

        {/* Selected File */}
        {file && (
          <div className="mt-6 p-4 bg-purple-50 rounded-lg">
            <div className="flex items-center justify-between">
              <div className="flex items-center">
                <span className="text-2xl mr-3">📄</span>
                <div className="text-left">
                  <p className="font-medium text-gray-800">{file.name}</p>
                  <p className="text-sm text-gray-500">
                    {(file.size / 1024 / 1024).toFixed(2)} MB
                  </p>
                </div>
              </div>
              <button
                onClick={() => setFile(null)}
                className="text-red-500 hover:text-red-700"
              >
                ✕
              </button>
            </div>
          </div>
        )}

        {/* Error Message */}
        {error && (
          <div className="mt-4 p-4 bg-red-50 border border-red-200 rounded-lg">
            <p className="text-red-600">{error}</p>
          </div>
        )}

        {/* Upload Button */}
        <button
          onClick={handleUpload}
          disabled={!file || uploading}
          className={`mt-8 px-8 py-4 rounded-xl font-bold text-lg transition-all ${
            file && !uploading
              ? 'bg-gradient-to-r from-purple-600 to-blue-600 text-white hover:shadow-xl hover:scale-105'
              : 'bg-gray-300 text-gray-500 cursor-not-allowed'
          }`}
        >
          {uploading ? (
            <span className="flex items-center">
              <svg className="animate-spin h-5 w-5 mr-3" viewBox="0 0 24 24">
                <circle
                  className="opacity-25"
                  cx="12"
                  cy="12"
                  r="10"
                  stroke="currentColor"
                  strokeWidth="4"
                  fill="none"
                />
                <path
                  className="opacity-75"
                  fill="currentColor"
                  d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                />
              </svg>
              Uploading...
            </span>
          ) : (
            'Upload & Continue'
          )}
        </button>
      </div>
    </div>
  )
}
