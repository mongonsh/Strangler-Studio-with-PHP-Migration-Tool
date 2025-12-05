import { useState } from 'react'
import Input from './components/Input'
import Analysis from './components/Analysis'
import Generate from './components/Generate'
import Download from './components/Download'
import './frankenstein-theme.css'

function App() {
  const [step, setStep] = useState(1)
  const [uploadId, setUploadId] = useState(null)
  const [analysis, setAnalysis] = useState(null)
  const [generated, setGenerated] = useState(null)

  const steps = [
    { number: 1, name: 'Source', component: Input },
    { number: 2, name: 'Analyze', component: Analysis },
    { number: 3, name: 'Transform', component: Generate },
    { number: 4, name: 'Extract', component: Download },
  ]

  const handleInputComplete = (id) => {
    setUploadId(id)
    setStep(2)
  }

  const handleAnalysisComplete = (data) => {
    setAnalysis(data)
    setStep(3)
  }

  const handleGenerateComplete = (data) => {
    setGenerated(data)
    setStep(4)
  }

  const CurrentStepComponent = steps[step - 1].component

  return (
    <div className="min-h-screen py-12 px-4" style={{ position: 'relative', zIndex: 1 }}>
      <div className="max-w-7xl mx-auto">
        {/* Header with Animated Logo */}
        <div className="text-center mb-16">
          <div className="logo-container mb-8">
            <img 
              src="/frankshtein.png" 
              alt="Frankenstein PHP Logo" 
              className="frankenstein-logo"
            />
          </div>
          <h1 className="title-frankenstein text-6xl mb-6">
            Frankenstein Laboratory
          </h1>
          <p className="subtitle-lab">
            Reanimating Legacy PHP into Modern Python
          </p>
        </div>

        {/* Experiment Stages */}
        <div className="mb-16">
          <div className="flex justify-between items-center max-w-4xl mx-auto">
            {steps.map((s, index) => (
              <div key={s.number} className="flex items-center flex-1">
                <div className="flex flex-col items-center flex-1">
                  <div
                    className={`experiment-stage ${
                      step === s.number ? 'active' : step > s.number ? 'completed' : ''
                    }`}
                  >
                    {s.number}
                  </div>
                  <span
                    className="mt-4 text-sm font-medium uppercase tracking-wider"
                    style={{
                      fontFamily: 'var(--font-title)',
                      color: step >= s.number ? 'var(--color-electric-blue)' : 'rgba(245, 245, 245, 0.3)'
                    }}
                  >
                    {s.name}
                  </span>
                </div>
                {index < steps.length - 1 && (
                  <div
                    className={`stage-connector ${step > s.number ? 'active' : ''}`}
                  />
                )}
              </div>
            ))}
          </div>
        </div>

        {/* Main Laboratory */}
        <div className="lab-container p-12">
          <CurrentStepComponent
            uploadId={uploadId}
            analysis={analysis}
            generated={generated}
            onInputComplete={handleInputComplete}
            onAnalysisComplete={handleAnalysisComplete}
            onGenerateComplete={handleGenerateComplete}
          />
        </div>

        {/* Footer */}
        <div className="text-center mt-12" style={{ color: 'rgba(245, 245, 245, 0.4)', fontSize: '0.875rem' }}>
          <p style={{ fontFamily: 'var(--font-body)', fontStyle: 'italic' }}>
            "It's alive! It's alive!" — Dr. Victor Frankenstein
          </p>
        </div>
      </div>
    </div>
  )
}

export default App
