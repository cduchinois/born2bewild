import { Router } from 'express';
import { IndexController } from '../controllers';

const router = Router();
const indexController = new IndexController();

export function setRoutes(app: Router) {
    app.post('/api/create-nft', indexController.createNFT.bind(indexController));
    app.post('/api/update-nft', indexController.updateNFT.bind(indexController));
    app.get('/api/fetch-nft', indexController.fetchNFT.bind(indexController));
    app.get('/api/fetch-collection', indexController.fetchNftCollection.bind(indexController));
    app.get('/api/fetch-collection-assets', indexController.fetchNftCollectionAssets.bind(indexController));
    app.get('/', (req, res) => {
        res.send('Welcome to the Wild SOL Server App API!');
    });
}

export default router;