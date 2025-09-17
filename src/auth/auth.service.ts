import { Injectable, UnauthorizedException } from '@nestjs/common';
import { UserService } from 'src/user/user.service';

@Injectable()
export class AuthService {
  constructor(private readonly userService: UserService) {}

  async singIn(username: string, password: string): Promise<any> {
    const user = await this.userService.findByUsernameAndPassword(username, password);

    if (!user) {
      throw new UnauthorizedException('用户名或密码错误');
    }

    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { password: p, ...userInfo } = user.toObject();

    // 不返回 password 字段
    return userInfo;
  }
}
