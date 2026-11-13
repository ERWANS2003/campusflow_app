// Serveur simulé de CampusFlow (séance 7).
//
// json-server transforme db.json en API REST complète :
//   GET    /taches        lister          POST   /taches      créer
//   GET    /taches/:id    lire            PATCH  /taches/:id  modifier (cocher)
//   DELETE /taches/:id    supprimer       GET    /cours        lister les cours
//
// On y ajoute une connexion simulée :
//   POST /login  {email, motDePasse}  →  200 {jeton, utilisateur}  ou 401
//   GET  /me                          →  l'utilisateur du jeton     ou 401
// Toutes les autres adresses exigent l'en-tête « Authorization: Bearer <jeton> »,
// sinon le serveur répond 401 (non authentifié).
//
// Lancer : npm install, puis npm start (port 3000).

const path = require('path');
const crypto = require('crypto');
const jsonServer = require('json-server');

const PORT = Number(process.env.PORT) || 3000;
const DUREE_JETON_MS = 60 * 60 * 1000; // un jeton expire au bout d'une heure

const server = jsonServer.create();
const router = jsonServer.router(path.join(__dirname, 'db.json'));
const jetons = new Map(); // jeton → { userId, expire }

server.use(jsonServer.defaults()); // journal, CORS, pas de cache
server.use(jsonServer.bodyParser);

const sansSecret = ({ motDePasse, ...utilisateur }) => utilisateur;

server.post('/login', (req, res) => {
  const { email, motDePasse } = req.body || {};
  const utilisateur = router.db
    .get('utilisateurs')
    .find({ email, motDePasse })
    .value();
  if (!utilisateur) {
    return res.status(401).json({ message: 'Email ou mot de passe incorrect.' });
  }
  const jeton = crypto.randomUUID();
  jetons.set(jeton, { userId: utilisateur.id, expire: Date.now() + DUREE_JETON_MS });
  res.json({ jeton, utilisateur: sansSecret(utilisateur) });
});

// Vérifie le jeton de chaque requête suivante.
server.use((req, res, next) => {
  if (req.method === 'OPTIONS') return next(); // pré-vérification CORS du navigateur
  const entete = req.headers.authorization || '';
  const jeton = entete.startsWith('Bearer ') ? entete.slice(7) : null;
  const session = jeton && jetons.get(jeton);
  if (!session || session.expire < Date.now()) {
    if (jeton) jetons.delete(jeton);
    return res.status(401).json({ message: 'Jeton absent ou expiré.' });
  }
  req.userId = session.userId;
  next();
});

server.get('/me', (req, res) => {
  const utilisateur = router.db.get('utilisateurs').find({ id: req.userId }).value();
  res.json(sansSecret(utilisateur));
});

// Les mots de passe ne sortent jamais par l'API.
server.use('/utilisateurs', (req, res) => res.status(403).json({ message: 'Interdit.' }));

server.use(router);

server.listen(PORT, () => {
  console.log(`CampusFlow API sur http://localhost:${PORT}`);
  console.log('Compte de démo : amina@etudiant.bf / campus');
});
