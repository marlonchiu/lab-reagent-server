import { Controller, Post, Body } from '@nestjs/common';
import { AuthService } from './auth.service';
import { UserDto } from 'src/user/dto/user.dto';
import { ApiTags } from '@nestjs/swagger';

@Controller('auth')
@ApiTags('授权管理 Auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('/login')
  async login(@Body() userInfo: UserDto) {
    const { username, password } = userInfo;
    return this.authService.singIn(username, password);
  }
}
