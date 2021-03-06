Get-Module Qlik-Cli | Remove-Module -Force
Import-Module (Resolve-Path "$PSScriptRoot\..\Qlik-Cli.psm1").Path
. (Resolve-Path "$PSScriptRoot\..\resources\rule.ps1").Path
. (Resolve-Path "$PSScriptRoot\..\functions\helper.ps1").Path
. (Resolve-Path "$PSScriptRoot\..\resources\tag.ps1").Path
. (Resolve-Path "$PSScriptRoot\..\resources\customproperty.ps1").Path

Describe "New-QlikRule" {
  Mock Invoke-QlikPost -Verifiable {
    return ConvertFrom-Json $body
  }

  Context 'Create rule from parameters' {
    Mock Get-QlikTag {
      return @(@{
        id = '177cf33f-1ace-41e8-8382-1c443a51352d'
      })
    }
    Mock Get-QlikCustomProperty {
      return @(@{
        id = 'daa5005e-5f3b-45c5-b2fd-1a1c92c5f367'
      })
    }

    It 'should create a rule with all parameters' {
      $rule = New-QlikRule `
        -name 'Custom Rule' `
        -category 'Security' `
        -rule '(name = "me")' `
        -resourceFilter 'Stream_*' `
        -actions 1 `
        -ruleContext 'BothQlikSenseAndQMC' `
        -tags 'testing' `
        -customProperties 'environment=development'

      $rule.name | Should Be 'Custom Rule'
      $rule.rule | Should Be '(name = "me")'
      $rule.resourceFilter | Should Be 'Stream_*'
      $rule.actions | Should Be 1
      $rule.category | Should Be 'Security'
      $rule.ruleContext | Should Be 'BothQlikSenseAndQMC'
      $rule.tags | Should -HaveCount 1
      $rule.customProperties | Should -HaveCount 1

      Assert-VerifiableMock
    }
  }
}

Describe "Update-QlikRule" {
  Mock Invoke-QlikPut -Verifiable {
    return ConvertFrom-Json $body
  }

  Mock Get-QlikRule -ParameterFilter {
    $id -eq 'e46cc4b4-b248-401a-a2fe-b3170532cc00'
  } {
    return @{
      id = 'e46cc4b4-b248-401a-a2fe-b3170532cc00'
      disabled = $false
      tags = @(@{
        id = '1b029edc-9c86-4e01-8c39-a10b1d9c4424'
      })
      customProperties = @(@{
        id = 'a834722d-1306-499e-b028-11454240381b'
      })
    }
  }
  Mock Get-QlikRule -ParameterFilter {
    $id -eq '3ed244ee-a5d7-4211-a16a-7cf54141e5ca'
  } {
    return @{
      id = '3ed244ee-a5d7-4211-a16a-7cf54141e5ca'
      disabled = $true
    }
  }

  Context 'State' {
    It 'should be possible to disable a rule' {
      $rule = Update-QlikRule `
        -id 'e46cc4b4-b248-401a-a2fe-b3170532cc00' `
        -Disabled

      $rule.disabled | Should BeOfType boolean
      $rule.disabled | Should BeTrue

      Assert-VerifiableMock
    }

    It 'should be possible to enable a rule' {
      $rule = Update-QlikRule `
        -id '3ed244ee-a5d7-4211-a16a-7cf54141e5ca' `
        -Disabled:$false

      $rule.disabled | Should BeOfType boolean
      $rule.disabled | Should BeFalse

      Assert-VerifiableMock
    }

    It 'should not disable a rule if disabled switch is not present' {
      $rule = Update-QlikRule `
        -id 'e46cc4b4-b248-401a-a2fe-b3170532cc00'

      $rule.disabled | Should BeOfType boolean
      $rule.disabled | Should BeFalse

      Assert-VerifiableMock
    }
  }

  Context 'tags' {
    Mock Get-QlikTag {
      return $null
    }

    It 'should be possible to remove all tags' {
      $dc = Update-QlikRule `
        -id 'e46cc4b4-b248-401a-a2fe-b3170532cc00' `
        -tags $null

      $dc.tags | Should -BeNullOrEmpty

      Assert-VerifiableMock
    }

    It 'should not remove tags if parameter not provided' {
      $dc = Update-QlikRule `
        -id 'e46cc4b4-b248-401a-a2fe-b3170532cc00'

      $dc.tags | Should -HaveCount 1

      Assert-VerifiableMock
    }
  }

  Context 'custom property' {
    Mock Get-QlikCustomProperty {
      return $null
    }

    It 'should be possible to remove all custom properties' {
      $dc = Update-QlikRule `
        -id 'e46cc4b4-b248-401a-a2fe-b3170532cc00' `
        -customProperties $null

      $dc.customProperties | Should -BeNullOrEmpty

      Assert-VerifiableMock
    }

    It 'should not remove custom properties if parameter not provided' {
      $dc = Update-QlikRule `
        -id 'e46cc4b4-b248-401a-a2fe-b3170532cc00'

      $dc.customProperties | Should -HaveCount 1

      Assert-VerifiableMock
    }
  }
}
