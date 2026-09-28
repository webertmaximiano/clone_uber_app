#!/usr/bin/env node

/**
 * 🔍 Verificação de Pré-Requisitos para Teste de Integração
 * 
 * Este script verifica se tudo está pronto para executar o teste
 * 
 * Uso:
 *   node check_prerequisites.js
 */

const fs = require("fs");
const path = require("path");
const { execSync } = require("child_process");
const colors = require("colors");

const checks = {
  completed: 0,
  failed: 0,
  warnings: 0,
};

// ============================================================================
// UTILITIES
// ============================================================================

function pass(name, message) {
  console.log(colors.green("✅ PASS") + ` | ${name}`);
  if (message) console.log(colors.gray(`   → ${message}`));
  checks.completed++;
}

function fail(name, message) {
  console.log(colors.red("❌ FAIL") + ` | ${name}`);
  if (message) console.log(colors.red(`   → ${message}`));
  checks.failed++;
}

function warn(name, message) {
  console.log(colors.yellow("⚠️  WARN") + ` | ${name}`);
  if (message) console.log(colors.yellow(`   → ${message}`));
  checks.warnings++;
}

function section(title) {
  console.log("\n" + colors.bold.cyan(title));
  console.log(colors.gray("═".repeat(60)));
}

function command(cmd) {
  try {
    return execSync(cmd, { encoding: "utf8", stdio: "pipe" }).trim();
  } catch (e) {
    return null;
  }
}

function fileExists(filepath) {
  return fs.existsSync(filepath);
}

function directoryExists(dirpath) {
  return fs.existsSync(dirpath) && fs.statSync(dirpath).isDirectory();
}

// ============================================================================
// CHECKS
// ============================================================================

function checkNodeJS() {
  section("📦 Node.js & npm");

  const nodeVersion = command("node --version");
  if (nodeVersion) {
    pass("Node.js", `Versão ${nodeVersion}`);
  } else {
    fail("Node.js", "Node.js não instalado. Visite: https://nodejs.org");
  }

  const npmVersion = command("npm --version");
  if (npmVersion) {
    pass("npm", `Versão ${npmVersion}`);
  } else {
    fail("npm", "npm não instalado");
  }
}

function checkFirebaseCLI() {
  section("🔥 Firebase CLI");

  const firebaseVersion = command("firebase --version");
  if (firebaseVersion) {
    pass("Firebase CLI", `Versão ${firebaseVersion}`);

    const isLoggedIn = command("firebase projects:list 2>/dev/null");
    if (isLoggedIn && isLoggedIn.length > 0) {
      pass("Firebase Login", "Autenticado ✓");
    } else {
      fail("Firebase Login", "Execute: firebase login");
    }
  } else {
    fail("Firebase CLI", "Não instalado. Execute: npm install -g firebase-tools");
  }
}

function checkProjectStructure() {
  section("📁 Estrutura do Projeto");

  const requiredDirs = [
    "apps/users_app",
    "apps/drivers_app",
    "apps/admin_web_panel",
    "functions",
    "docs",
  ];

  requiredDirs.forEach((dir) => {
    if (directoryExists(dir)) {
      pass(`Diretório: ${dir}`);
    } else {
      fail(`Diretório: ${dir}`, "Não encontrado");
    }
  });

  const requiredFiles = [
    "firebase.json",
    "functions/index.js",
    "functions/package.json",
    "apps/admin_web_panel/pubspec.yaml",
  ];

  requiredFiles.forEach((file) => {
    if (fileExists(file)) {
      pass(`Arquivo: ${file}`);
    } else {
      fail(`Arquivo: ${file}`, "Não encontrado");
    }
  });
}

function checkCloudFunctions() {
  section("☁️  Cloud Functions");

  if (!fileExists("functions/index.js")) {
    fail("functions/index.js", "Arquivo não encontrado");
    return;
  }

  const content = fs.readFileSync("functions/index.js", "utf8");

  const functions = [
    { name: "sendRideStatusNotification", pattern: /exports\.sendRideStatusNotification/ },
    { name: "notifyNearbyDrivers", pattern: /exports\.notifyNearbyDrivers/ },
    { name: "cleanupOldNotifications", pattern: /exports\.cleanupOldNotifications/ },
    { name: "cleanupOldRideNotifications", pattern: /exports\.cleanupOldRideNotifications/ },
    { name: "retryFailedNotifications", pattern: /exports\.retryFailedNotifications/ },
  ];

  functions.forEach((fn) => {
    if (fn.pattern.test(content)) {
      pass(`Function: ${fn.name}`);
    } else {
      fail(`Function: ${fn.name}`, "Não encontrada em functions/index.js");
    }
  });

  // Verificar dependencies
  const pkgPath = "functions/package.json";
  if (fileExists(pkgPath)) {
    const pkg = JSON.parse(fs.readFileSync(pkgPath, "utf8"));
    const requiredDeps = ["firebase-admin", "firebase-functions"];

    requiredDeps.forEach((dep) => {
      if (pkg.dependencies && pkg.dependencies[dep]) {
        pass(`Dependency: ${dep}@${pkg.dependencies[dep]}`);
      } else {
        fail(`Dependency: ${dep}`, "Não encontrada em functions/package.json");
      }
    });
  }
}

function checkFirebaseConfig() {
  section("🔧 Configuração Firebase");

  if (!fileExists("firebase.json")) {
    fail("firebase.json", "Arquivo não encontrado");
    return;
  }

  try {
    const config = JSON.parse(fs.readFileSync("firebase.json", "utf8"));

    if (config.projects && config.projects.default) {
      pass("Firebase Project", `Configurado: ${config.projects.default}`);
    } else {
      warn("Firebase Project", "Verifique firebase.json para múltiplos projetos");
    }

    if (config.functions) {
      pass("Functions Config", "Encontrado em firebase.json");
    } else {
      fail("Functions Config", "Não configurado em firebase.json");
    }

    if (config.firestore) {
      pass("Firestore Config", "Encontrado em firebase.json");
    } else {
      warn("Firestore Config", "Não configurado explicitamente");
    }
  } catch (e) {
    fail("firebase.json", `Erro ao parsear: ${e.message}`);
  }
}

function checkFlutterApps() {
  section("📱 Flutter Apps");

  const apps = [
    { name: "Users App", path: "apps/users_app" },
    { name: "Drivers App", path: "apps/drivers_app" },
    { name: "Admin Web Panel", path: "apps/admin_web_panel" },
  ];

  apps.forEach((app) => {
    if (directoryExists(app.path)) {
      pass(`${app.name} (${app.path})`);

      // Verificar pubspec.yaml
      const pubspecPath = path.join(app.path, "pubspec.yaml");
      if (fileExists(pubspecPath)) {
        pass(`  └─ pubspec.yaml`);
      } else {
        fail(`  └─ pubspec.yaml`, "Não encontrado");
      }

      // Verificar lib/main.dart
      const mainPath = path.join(app.path, "lib/main.dart");
      if (fileExists(mainPath)) {
        pass(`  └─ lib/main.dart`);
      } else {
        fail(`  └─ lib/main.dart`, "Não encontrado");
      }
    } else {
      fail(`${app.name}`, `Diretório não encontrado: ${app.path}`);
    }
  });
}

function checkAdminWebBuild() {
  section("🌐 Admin Web Panel Build");

  const buildDir = "apps/admin_web_panel/build/web";

  if (directoryExists(buildDir)) {
    pass("Build Directory", "build/web encontrado");

    const requiredFiles = ["index.html", "flutter.js", "flutter_bootstrap.js"];

    requiredFiles.forEach((file) => {
      const filePath = path.join(buildDir, file);
      if (fileExists(filePath)) {
        pass(`  └─ ${file}`);
      } else {
        warn(`  └─ ${file}`, "Não encontrado - execute: flutter build web --release");
      }
    });
  } else {
    warn("Admin Web Build", "build/web não encontrado");
    console.log(colors.yellow("   Recompile: cd apps/admin_web_panel && flutter build web --release"));
  }
}

function checkDocumentation() {
  section("📚 Documentação");

  const docs = [
    { name: "Integration Test Plan", path: "INTEGRATION_TEST_PLAN.md" },
    { name: "Integration Test Manual", path: "INTEGRATION_TEST_MANUAL.md" },
    { name: "Integration Test Quickstart", path: "INTEGRATION_TEST_QUICKSTART.md" },
    { name: "Cloud Functions Guide", path: "CLOUD_FUNCTIONS_GUIDE.md" },
    { name: "README", path: "README.md" },
  ];

  docs.forEach((doc) => {
    if (fileExists(doc.path)) {
      pass(`${doc.name}`);
    } else {
      warn(`${doc.name}`, `${doc.path} não encontrado`);
    }
  });
}

function checkServices() {
  section("🚀 Serviços Necessários");

  // Check Python (para http.server)
  const pythonVersion = command("python --version");
  if (pythonVersion) {
    pass("Python", `${pythonVersion}`);
  } else {
    const python3Version = command("python3 --version");
    if (python3Version) {
      pass("Python 3", `${python3Version}`);
    } else {
      warn("Python", "Não encontrado (necessário para servir admin panel)");
    }
  }

  // Check Android/iOS emulator availability
  warn("Emulators", "Verifique manualmente: flutter devices");
}

// ============================================================================
// REPORT
// ============================================================================

function generateReport() {
  console.log("\n" + colors.bold.cyan("═".repeat(60)));
  console.log(colors.bold.cyan("📊 RELATÓRIO DE PRÉ-REQUISITOS"));
  console.log(colors.bold.cyan("═".repeat(60)));

  const total = checks.completed + checks.failed + checks.warnings;
  const percentage = Math.round((checks.completed / total) * 100);

  console.log(`\n${colors.green(`✅ Passou:`)}     ${checks.completed}/${total}`);
  console.log(`${colors.red(`❌ Falhou:`)}     ${checks.failed}/${total}`);
  console.log(`${colors.yellow(`⚠️  Avisos:`)}     ${checks.warnings}/${total}`);
  console.log(`\n${colors.bold(`Sucesso: ${percentage}%`)}`);

  // Status geral
  console.log("\n" + colors.bold("Status Geral:"));
  if (checks.failed === 0) {
    console.log(colors.green("✅ TUDO PRONTO PARA TESTE"));
    console.log(colors.gray("\nProximos passos:"));
    console.log("1. Abra 4 terminais diferentes");
    console.log("2. Terminal 1: firebase functions:log");
    console.log("3. Terminal 2: cd apps/admin_web_panel/build/web && python -m http.server 8888");
    console.log("4. Terminal 3 & 4: Abra os emuladores com flutter run");
    console.log("\nDepois siga: INTEGRATION_TEST_QUICKSTART.md");
  } else if (checks.warnings === 0) {
    console.log(colors.yellow("⚠️  FALHAS ENCONTRADAS"));
    console.log(colors.gray("Resolva os items marcados com ❌ antes de fazer o teste"));
  } else {
    console.log(colors.yellow("⚠️  POSSÍVEIS PROBLEMAS"));
    console.log(colors.gray("Revise os items marcados com ⚠️ antes de fazer o teste"));
  }

  console.log("\n" + colors.gray("═".repeat(60)));

  // Exit code
  process.exit(checks.failed > 0 ? 1 : 0);
}

// ============================================================================
// MAIN
// ============================================================================

console.log(colors.bold.cyan("\n🔍 Verificação de Pré-Requisitos\n"));

checkNodeJS();
checkFirebaseCLI();
checkProjectStructure();
checkCloudFunctions();
checkFirebaseConfig();
checkFlutterApps();
checkAdminWebBuild();
checkDocumentation();
checkServices();

generateReport();
