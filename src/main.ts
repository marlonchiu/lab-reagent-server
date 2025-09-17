import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { TransformInterceptor } from './transform/transform.interceptor';
import { HttpExceptionFilter } from './http-exception/http-exception.filter';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.setGlobalPrefix('api'); // 路由全局前缀

  app.useGlobalInterceptors(new TransformInterceptor()); // 全局拦截器

  app.useGlobalFilters(new HttpExceptionFilter()); // 全局过滤器

  app.enableCors(); // 允许跨域

  const swaggerConfig = new DocumentBuilder()
    .setTitle('试剂预约接口文档')
    .setDescription('描述...')
    .setVersion('1.0')
    .build();
  const documentFactory = () => SwaggerModule.createDocument(app, swaggerConfig);
  SwaggerModule.setup('/api-docs', app, documentFactory);

  await app.listen(process.env.PORT ?? 3000);
}

// eslint-disable-next-line @typescript-eslint/no-floating-promises
bootstrap();
