import 'dotenv/config';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { pool, query } from '../config/database.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

/**
 * Script de seed para popular o banco de dados com dados iniciais.
 *
 * Uso: npm run seed
 *
 * IMPORTANTE: Os dados abaixo são demonstrativos. Para o município-piloto real,
 * substitua por endereços e coordenadas verificadas.
 */
async function seed() {
  console.log('\n🌱 Iniciando seed do banco de dados...\n');

  // ── 1. Executar schema SQL ────────────────────────────────────────────────

  try {
    const schemaPath = path.join(__dirname, 'schema.sql');
    const schemaSql = fs.readFileSync(schemaPath, 'utf-8');
    await query(schemaSql);
    console.log('✅ Schema criado/atualizado');
  } catch (err: any) {
    console.error('❌ Erro ao executar schema:', err.message);
    process.exit(1);
  }

  // ── 2. Inserir instituições de demonstração ───────────────────────────────
  // Coordenadas e endereços são ilustrativos (região de São Paulo).
  // Devem ser substituídos por dados reais do município-piloto.

  const institutions = [
    {
      name: 'DEAM Centro — Delegacia da Mulher',
      category: 'delegacia_mulher',
      address: 'Rua Dr. Falcão Filho, 100 - Centro',
      city: 'São Paulo',
      state: 'SP',
      zip_code: '01007-010',
      phone: '(11) 3101-1234',
      lat: -23.5437,
      lng: -46.6380,
      services: ['boletim_ocorrencia', 'medida_protetiva', 'acolhimento'],
      opening_hours: { seg: '24h', ter: '24h', qua: '24h', qui: '24h', sex: '24h', sab: '24h', dom: '24h' },
    },
    {
      name: '1ª DDM — Delegacia de Defesa da Mulher',
      category: 'delegacia_mulher',
      address: 'Rua Augusta, 235 - Consolação',
      city: 'São Paulo',
      state: 'SP',
      zip_code: '01305-000',
      phone: '(11) 3151-5678',
      lat: -23.5519,
      lng: -46.6558,
      services: ['boletim_ocorrencia', 'medida_protetiva'],
      opening_hours: { seg: '08:00-18:00', ter: '08:00-18:00', qua: '08:00-18:00', qui: '08:00-18:00', sex: '08:00-18:00' },
    },
    {
      name: 'CREAS Centro',
      category: 'creas',
      address: 'Rua Libero Badaró, 600 - Centro',
      city: 'São Paulo',
      state: 'SP',
      zip_code: '01008-000',
      phone: '(11) 3104-5678',
      lat: -23.5470,
      lng: -46.6350,
      services: ['acolhimento', 'orientacao_juridica', 'atendimento_psicologico'],
      opening_hours: { seg: '08:00-17:00', ter: '08:00-17:00', qua: '08:00-17:00', qui: '08:00-17:00', sex: '08:00-17:00' },
    },
    {
      name: 'CRAS Sé',
      category: 'cras',
      address: 'Rua Álvares Penteado, 100 - Centro',
      city: 'São Paulo',
      state: 'SP',
      zip_code: '01012-000',
      phone: '(11) 3101-0000',
      lat: -23.5450,
      lng: -46.6345,
      services: ['cadastro_unico', 'beneficios', 'orientacao_social'],
      opening_hours: { seg: '08:00-17:00', ter: '08:00-17:00', qua: '08:00-17:00', qui: '08:00-17:00', sex: '08:00-17:00' },
    },
    {
      name: 'Defensoria Pública do Estado de SP — Núcleo da Mulher',
      category: 'defensoria',
      address: 'Rua Boa Vista, 200 - Centro',
      city: 'São Paulo',
      state: 'SP',
      zip_code: '01014-000',
      phone: '(11) 3105-1234',
      lat: -23.5455,
      lng: -46.6332,
      services: ['orientacao_juridica', 'medida_protetiva', 'divorcio'],
      opening_hours: { seg: '09:00-17:00', ter: '09:00-17:00', qua: '09:00-17:00', qui: '09:00-17:00', sex: '09:00-17:00' },
    },
    {
      name: 'Hospital Municipal Dr. Cármino Caricchio',
      category: 'hospital',
      address: 'Av. Celso Garcia, 4815 - Tatuapé',
      city: 'São Paulo',
      state: 'SP',
      zip_code: '03063-000',
      phone: '(11) 2799-0000',
      lat: -23.5360,
      lng: -46.5720,
      services: ['urgencia', 'atendimento_vitimas_violencia'],
      opening_hours: { seg: '24h', ter: '24h', qua: '24h', qui: '24h', sex: '24h', sab: '24h', dom: '24h' },
    },
    {
      name: 'Centro de Referência da Mulher — Casa Eliane de Grammont',
      category: 'centro_referencia',
      address: 'Rua Dr. Bittencourt Rodrigues, 200 - Sé',
      city: 'São Paulo',
      state: 'SP',
      zip_code: '01020-040',
      phone: '(11) 3106-1234',
      lat: -23.5490,
      lng: -46.6310,
      services: ['atendimento_psicologico', 'orientacao_juridica', 'grupo_apoio'],
      opening_hours: { seg: '08:00-17:00', ter: '08:00-17:00', qua: '08:00-17:00', qui: '08:00-17:00', sex: '08:00-17:00' },
    },
    {
      name: 'Ministério Público — Promotoria de Violência Doméstica',
      category: 'ministerio_publico',
      address: 'Rua Riachuelo, 115 - Sé',
      city: 'São Paulo',
      state: 'SP',
      zip_code: '01007-000',
      phone: '(11) 3103-0000',
      lat: -23.5480,
      lng: -46.6370,
      services: ['denuncia', 'medida_protetiva', 'acompanhamento_processo'],
      opening_hours: { seg: '09:00-18:00', ter: '09:00-18:00', qua: '09:00-18:00', qui: '09:00-18:00', sex: '09:00-18:00' },
    },
  ];

  for (const inst of institutions) {
    try {
      await query(
        `INSERT INTO institutions (name, category, address, city, state, zip_code, phone, location, services, opening_hours, verified_at)
         VALUES ($1, $2, $3, $4, $5, $6, $7, ST_SetSRID(ST_MakePoint($8, $9), 4326)::geography, $10, $11, NOW())
         ON CONFLICT DO NOTHING`,
        [
          inst.name,
          inst.category,
          inst.address,
          inst.city,
          inst.state,
          inst.zip_code,
          inst.phone,
          inst.lng, // ST_MakePoint usa (longitude, latitude)
          inst.lat,
          inst.services,
          JSON.stringify(inst.opening_hours),
        ],
      );
      console.log(`  📍 ${inst.name}`);
    } catch (err: any) {
      console.error(`  ❌ Erro ao inserir ${inst.name}:`, err.message);
    }
  }

  // ── 3. Inserir guias de orientação ────────────────────────────────────────

  const guides = [
    {
      slug: 'emergencia',
      title: 'Em caso de emergência',
      icon: '🔴',
      category: 'emergencia',
      priority: 100,
      summary: 'Saiba o que fazer em uma situação de risco imediato.',
      content: `# Em caso de emergência

## Risco imediato? Ligue 190.

O **190** é o número da Polícia Militar. A ligação é gratuita e funciona 24 horas.

### O que falar:
- Diga que precisa de ajuda.
- Informe seu endereço ou localização, se souber.
- Descreva brevemente a situação.
- Se não puder falar, mantenha a linha aberta — a central pode rastrear a chamada.

## Precisa de orientação? Ligue 180.

O **Ligue 180** é a Central de Atendimento à Mulher:
- Funciona **24 horas**, **7 dias por semana**.
- A ligação é **gratuita e sigilosa**.
- Atende em português, espanhol e inglês.
- Orienta sobre direitos, serviços de proteção e como denunciar.

## Não está em risco imediato?

Se você está planejando sair de uma situação de violência, veja o guia "Plano de segurança" neste app. Não há pressa — cada passo conta.`,
    },
    {
      slug: 'boletim-de-ocorrencia',
      title: 'Como fazer um Boletim de Ocorrência',
      icon: '📋',
      category: 'direitos',
      priority: 90,
      summary: 'Passo a passo para registrar um B.O. presencial ou online.',
      content: `# Como fazer um Boletim de Ocorrência

## Presencial

1. Vá a uma **Delegacia da Mulher (DEAM)** ou a qualquer delegacia.
2. Relate o que aconteceu com o máximo de detalhes.
3. A autoridade policial é obrigada a registrar o B.O.
4. Peça a **medida protetiva** no momento do registro (é seu direito).
5. Guarde uma cópia do B.O.

## Online

Muitos estados possuem **Delegacia Eletrônica**:
- São Paulo: delegaciaeletronica.policiacivil.sp.gov.br
- Rio de Janeiro: rfrj.pcivil.rj.gov.br
- Minas Gerais: delegaciavirtual.sids.mg.gov.br

> **Atenção:** Para casos de estupro ou agressão em andamento, vá presencialmente ou ligue 190.

## O que levar (se possível)

- Documento com foto (RG, CNH)
- Prints de conversas, fotos de ferimentos
- Nomes de testemunhas
- Laudos médicos, se houver

## Importante

- Você **não precisa de advogado** para registrar o B.O.
- O atendimento deve ser **humanizado e sem julgamento**.
- Se não for bem atendida, procure a **Corregedoria** ou o **Ministério Público**.`,
    },
    {
      slug: 'medida-protetiva',
      title: 'Medida Protetiva de Urgência',
      icon: '🛡️',
      category: 'direitos',
      priority: 85,
      summary: 'O que é, como pedir e o que esperar da medida protetiva.',
      content: `# Medida Protetiva de Urgência

## O que é?

Uma **ordem judicial** que protege você do agressor. Pode incluir:
- Afastamento do agressor do lar
- Proibição de contato e aproximação
- Distância mínima obrigatória
- Restrição de visitas aos filhos
- Prestação de alimentos provisórios

## Como pedir?

1. **Na delegacia**: peça no momento do B.O. A autoridade tem **48 horas** para encaminhar ao juiz.
2. **Na Defensoria Pública**: atendimento gratuito para quem precisa.
3. **No Ministério Público**: a promotoria pode encaminhar.

## Precisa de advogado?

**Não.** Você pode pedir a medida protetiva sem advogado.

## E se ele descumprir?

O descumprimento de medida protetiva é **crime** (Art. 24-A da Lei Maria da Penha), com pena de 3 meses a 2 anos de detenção. Ligue 190 imediatamente.

## Importante

A medida protetiva **não depende** de processo penal. Seu objetivo é a sua **proteção imediata**.`,
    },
    {
      slug: 'lei-maria-da-penha',
      title: 'Seus Direitos — Lei Maria da Penha',
      icon: '⚖️',
      category: 'direitos',
      priority: 80,
      summary: 'Conheça os tipos de violência e seus direitos garantidos por lei.',
      content: `# Lei Maria da Penha (Lei nº 11.340/2006)

A lei protege toda mulher, independentemente de classe, raça, etnia, orientação sexual, renda, cultura, nível educacional, idade ou religião.

## Tipos de violência reconhecidos

### Violência física
Tapas, empurrões, socos, queimaduras, uso de armas ou objetos.

### Violência psicológica
Ameaças, humilhações, controle, isolamento, manipulação, gaslighting.

### Violência sexual
Forçar relação sexual, impedir uso de contraceptivo, forçar gravidez ou aborto.

### Violência patrimonial
Destruir objetos, controlar dinheiro, reter documentos, causar dano ao patrimônio.

### Violência moral
Calúnia, difamação, injúria.

## Seus direitos

- Registrar B.O. em qualquer delegacia
- Pedir medida protetiva sem advogado
- Assistência jurídica gratuita na Defensoria Pública
- Escolta policial para retirar pertences
- Afastamento do agressor do lar
- Atendimento humanizado e sem culpabilização`,
    },
    {
      slug: 'apoio-financeiro',
      title: 'Apoio Financeiro',
      icon: '💰',
      category: 'financeiro',
      priority: 75,
      summary: 'Benefícios e programas disponíveis para recomeçar.',
      content: `# Apoio Financeiro para Mulheres em Situação de Violência

## Onde buscar

O **CRAS** (Centro de Referência de Assistência Social) é a porta de entrada:
- Avalia sua situação socioeconômica
- Cadastra no CadÚnico (Cadastro Único)
- Orienta sobre todos os benefícios disponíveis

## Benefícios possíveis

### Auxílio-aluguel
Alguns estados e municípios oferecem auxílio temporário para moradia:
- Geralmente exige medida protetiva e comprovação de vulnerabilidade
- Consulte a Secretaria de Assistência Social do seu município

### Afastamento remunerado do trabalho
O STF reconheceu o direito ao afastamento remunerado:
- **Com vínculo**: empregador paga os primeiros 15 dias, INSS o restante (até 6 meses)
- **Sem vínculo**: pode ser garantido via BPC ou auxílio assistencial

### BPC (Benefício de Prestação Continuada)
- Tradicionalmente para idosos ou PCD
- Pode ser aplicado em casos de violência doméstica com vulnerabilidade extrema

### CadÚnico
Dá acesso a programas como Bolsa Família, tarifa social de energia, isenções.

## O que levar ao CRAS

- RG e CPF
- Comprovante de residência
- Cópia da medida protetiva (se houver)
- Certidão de nascimento dos filhos`,
    },
    {
      slug: 'rede-de-atendimento',
      title: 'Rede de Atendimento',
      icon: '🏥',
      category: 'rede',
      priority: 70,
      summary: 'O que é cada serviço e quando procurar.',
      content: `# Rede de Atendimento à Mulher

## DEAM — Delegacia Especializada
Registra B.O., encaminha medida protetiva, acolhe e orienta. Funciona como porta de entrada para o sistema de Justiça.

## CREAS — Centro de Referência Especializado
Atendimento psicológico, jurídico e social para famílias e indivíduos em situação de violência. Equipe multidisciplinar.

## CRAS — Centro de Referência de Assistência Social
Acesso a benefícios, CadÚnico, orientação sobre programas sociais. É a porta de entrada da assistência.

## Defensoria Pública
Assistência jurídica gratuita: divórcio, guarda, pensão, medida protetiva, acompanhamento de processos.

## Ministério Público
Recebe denúncias, acompanha processos, pode pedir medida protetiva. Fiscaliza o cumprimento da lei.

## Casa-Abrigo
Abrigo sigiloso e temporário para mulheres e filhos em risco extremo. O endereço é mantido em sigilo absoluto.

## Centro de Referência da Mulher
Atendimento psicológico, grupos de apoio, orientação jurídica. Acolhe sem exigir B.O. ou processo.

## Hospital / UPA
Atendimento de urgência para ferimentos. Profissionais de saúde são obrigados a notificar casos de violência (sigilo mantido).`,
    },
    {
      slug: 'seguranca-digital',
      title: 'Segurança Digital',
      icon: '📱',
      category: 'seguranca',
      priority: 65,
      summary: 'Cuidados com o celular e proteção de informações.',
      content: `# Segurança Digital

## Cuidados básicos

- **Limpe o histórico** do navegador após pesquisar sobre violência doméstica
- Use o **modo anônimo** do navegador para pesquisas sensíveis
- Verifique se há apps de rastreamento instalados no seu celular
- Altere senhas que o agressor possa conhecer
- Ative a **verificação em duas etapas** do WhatsApp

## Apps de rastreamento

Sinais de que seu celular pode estar sendo monitorado:
- Bateria descarregando mais rápido que o normal
- Consumo de dados incomum
- Apps desconhecidos instalados
- Celular esquentando sem uso

> **Atenção:** Remover um app de rastreamento pode alertar o agressor. Avalie a situação antes de agir. Se possível, use outro celular para buscar ajuda.

## Limite honesto

Este app **não garante invisibilidade total**. O modo discreto altera a aparência, mas o app ainda aparece nas configurações, na loja e no histórico do celular.

## Dica

Se precisar de um celular seguro, organizações como a Casa-Abrigo e o CREAS podem ajudar.`,
    },
    {
      slug: 'apos-denuncia',
      title: 'Após a Denúncia — Próximos Passos',
      icon: '🔄',
      category: 'direitos',
      priority: 60,
      summary: 'O que esperar e como acompanhar após registrar a ocorrência.',
      content: `# Após a Denúncia

## O que acontece depois do B.O.?

1. A delegacia encaminha o pedido de medida protetiva ao juiz (prazo: **48 horas**).
2. O juiz analisa e decide sobre a medida protetiva.
3. Se concedida, o agressor é notificado oficialmente.
4. Um inquérito policial pode ser aberto para investigar o caso.
5. O Ministério Público decide se oferece denúncia (ação penal).

## Como acompanhar

- Guarde o número do B.O. e o protocolo da medida protetiva
- Procure a **Defensoria Pública** para acompanhamento gratuito
- Verifique o andamento no site do tribunal do seu estado

## Se ele descumprir a medida protetiva

- Ligue **190** imediatamente
- Registre novo B.O. por descumprimento
- O descumprimento é crime com pena de detenção

## Rede de apoio para recomeço

- **CRAS/CREAS**: assistência social e benefícios
- **Centro de Referência da Mulher**: apoio psicológico e grupos
- **Defensoria Pública**: questões de guarda, pensão, divórcio
- **ONGs locais**: apoio comunitário e empoderamento`,
    },
  ];

  for (const guide of guides) {
    try {
      await query(
        `INSERT INTO guides (slug, title, icon, summary, content, category, priority)
         VALUES ($1, $2, $3, $4, $5, $6, $7)
         ON CONFLICT (slug) DO UPDATE SET
           title = EXCLUDED.title,
           icon = EXCLUDED.icon,
           summary = EXCLUDED.summary,
           content = EXCLUDED.content,
           category = EXCLUDED.category,
           priority = EXCLUDED.priority,
           updated_at = now()`,
        [guide.slug, guide.title, guide.icon, guide.summary, guide.content, guide.category, guide.priority],
      );
      console.log(`  📖 ${guide.title}`);
    } catch (err: any) {
      console.error(`  ❌ Erro ao inserir guia ${guide.slug}:`, err.message);
    }
  }

  console.log('\n✅ Seed concluído!\n');
  await pool.end();
  process.exit(0);
}

seed().catch((err) => {
  console.error('❌ Erro fatal no seed:', err);
  process.exit(1);
});
