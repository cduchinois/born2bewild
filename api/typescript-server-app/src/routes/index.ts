import { Router } from 'express';
import { IndexController } from '../controllers';

const router = Router();
const indexController = new IndexController();

export function setRoutes(app: Router) {
    app.get('/api/get-action', indexController.getAction.bind(indexController));
    app.post('/api/post-action', indexController.postAction.bind(indexController));
}

export default router;