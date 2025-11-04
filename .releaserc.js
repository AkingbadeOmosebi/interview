// .releaserc.js
module.exports = { 
  branches: ['main'],
  repositoryUrl: "https://github.com/AkingbadeOmosebi/Opsfolio-Interview-App.git",
  plugins: [
    '@semantic-release/commit-analyzer',
    '@semantic-release/release-notes-generator',
    ['@semantic-release/changelog', { changelogFile: 'CHANGELOG.md' }],
    ['@semantic-release/exec', {
      // Put the plain version string into VERSION.txt for CI or humans
      prepareCmd: 'echo ${nextRelease.version} > VERSION.txt'
    }],
    ['@semantic-release/git', {
      assets: ['CHANGELOG.md', 'VERSION.txt'],
      message: 'chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}'
    }],
    '@semantic-release/github'
  ]
};