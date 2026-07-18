#Requires -Modules Pester

BeforeAll {
    $script:TrackSourceRoot = Split-Path -Path $PSScriptRoot -Parent
    $script:InitializeScript = Join-Path $script:TrackSourceRoot 'scripts/Initialize-CatesWorkspace.ps1'
    $script:ResetScript = Join-Path $script:TrackSourceRoot 'scripts/Reset-CatesWorkspace.ps1'
    $script:TemplateSource = Join-Path $script:TrackSourceRoot 'assets/workspace-template'
}

Describe 'CATES workspace lifecycle' -Tag 'Unit' {
    BeforeEach {
        $script:TrackRoot = Join-Path $TestDrive 'cates-exercises'
        $AssetRoot = Join-Path $script:TrackRoot 'assets'
        New-Item -Path $AssetRoot -ItemType Directory -Force | Out-Null
        Copy-Item -Path $script:TemplateSource -Destination $AssetRoot -Recurse
    }

    Context 'workspace initialization' {
        It 'creates a complete workspace from the immutable template' {
            & pwsh -NoProfile -File $script:InitializeScript -TrackRoot $script:TrackRoot

            $LASTEXITCODE | Should -Be 0
            Test-Path (Join-Path $script:TrackRoot 'workspace/sample-repository/.github/copilot-instructions.md') | Should -BeTrue
        }

        It 'preserves learner files when rerun against a complete workspace' {
            & pwsh -NoProfile -File $script:InitializeScript -TrackRoot $script:TrackRoot
            $MarkerPath = Join-Path $script:TrackRoot 'workspace/learner-progress.txt'
            Set-Content -Path $MarkerPath -Value 'preserve me'

            & pwsh -NoProfile -File $script:InitializeScript -TrackRoot $script:TrackRoot

            $LASTEXITCODE | Should -Be 0
            Get-Content -Path $MarkerPath -Raw | Should -Match 'preserve me'
        }

        It 'refuses to overwrite a partial workspace' {
            $WorkspaceRoot = Join-Path $script:TrackRoot 'workspace'
            New-Item -Path $WorkspaceRoot -ItemType Directory -Force | Out-Null
            Set-Content -Path (Join-Path $WorkspaceRoot 'partial.txt') -Value 'partial'

            & pwsh -NoProfile -File $script:InitializeScript -TrackRoot $script:TrackRoot 2>$null

            $LASTEXITCODE | Should -Be 1
            Test-Path (Join-Path $WorkspaceRoot 'partial.txt') | Should -BeTrue
        }
    }

    Context 'workspace reset' {
        BeforeEach {
            & pwsh -NoProfile -File $script:InitializeScript -TrackRoot $script:TrackRoot
            $LASTEXITCODE | Should -Be 0
        }

        It 'changes nothing during a WhatIf preview' {
            & pwsh -NoProfile -File $script:ResetScript -TrackRoot $script:TrackRoot -WhatIf

            $LASTEXITCODE | Should -Be 0
            Test-Path (Join-Path $script:TrackRoot 'workspace/sample-repository') | Should -BeTrue
            Test-Path (Join-Path $script:TrackRoot 'completed') | Should -BeFalse
        }

        It 'archives progress before restoring a clean workspace' {
            $ProgressPath = Join-Path $script:TrackRoot 'workspace/sample-repository/reports/final.json'
            Set-Content -Path $ProgressPath -Value '{"score": 90}'

            & pwsh -NoProfile -File $script:ResetScript -TrackRoot $script:TrackRoot -ArchiveTime '2026-07-18T12:30:00' -Confirm:$false

            $LASTEXITCODE | Should -Be 0
            Test-Path (Join-Path $script:TrackRoot 'completed/run-20260718-1230/sample-repository/reports/final.json') | Should -BeTrue
            Test-Path $ProgressPath | Should -BeFalse
            Test-Path (Join-Path $script:TrackRoot 'workspace/sample-repository/.github/copilot-instructions.md') | Should -BeTrue
        }

        It 'adds a numeric suffix when an archive name already exists' {
            & pwsh -NoProfile -File $script:ResetScript -TrackRoot $script:TrackRoot -ArchiveTime '2026-07-18T12:30:00' -Confirm:$false
            & pwsh -NoProfile -File $script:ResetScript -TrackRoot $script:TrackRoot -ArchiveTime '2026-07-18T12:30:00' -Confirm:$false

            $LASTEXITCODE | Should -Be 0
            Test-Path (Join-Path $script:TrackRoot 'completed/run-20260718-1230') | Should -BeTrue
            Test-Path (Join-Path $script:TrackRoot 'completed/run-20260718-1230-01') | Should -BeTrue
        }

        It 'does not change a sibling path outside the track root' {
            $SiblingPath = Join-Path $TestDrive 'unrelated.txt'
            Set-Content -Path $SiblingPath -Value 'unchanged'

            & pwsh -NoProfile -File $script:ResetScript -TrackRoot $script:TrackRoot -ArchiveTime '2026-07-18T12:30:00' -Confirm:$false

            $LASTEXITCODE | Should -Be 0
            Get-Content -Path $SiblingPath -Raw | Should -Match 'unchanged'
        }
    }
}