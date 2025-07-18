## [2.1.0] - 2025-07-17
- **Security Fix [CWE-502](https://cwe.mitre.org/data/definitions/502.html)**: 
  - Replace `YAML.load` with `YAML.safe_load` to prevent arbitrary code execution vulnerabilities.
  - Replace `YAML.load_file` with `YAML.safe_load_file` for safer YAML file loading.
- Update CI to use Ruby 3.4.5.
- Lock dependency gem version.
- Optimize rspec test.

## [2.0.3] - 2023-08-17
- Fix the bug that causes garbled characters when decrypting files.

## [2.0.2] - 2023-05-18
- Add gitlab templates.

## [2.0.1] - 2023-05-10
- Remove unsupport method at ruby 3.2.x.
- Fix Psych 4.x incompatibility issue.
