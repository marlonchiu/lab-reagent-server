import { Injectable, UnauthorizedException } from '@nestjs/common';
import { UserService } from 'src/user/user.service';
import { JwtService } from '@nestjs/jwt';

@Injectable()
export class AuthService {
  constructor(
    private readonly userService: UserService,
    private readonly jwtService: JwtService,
  ) {}

  async singIn(username: string, password: string): Promise<{ access_token: string }> {
    const user = await this.userService.findByUsernameAndPassword(username, password);

    if (!user) {
      throw new UnauthorizedException('用户名或密码错误');
    }

    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    const { password: p, ...userInfo } = user.toObject();

    // 不返回 password 字段
    // return userInfo;
    return {
      access_token: await this.jwtService.signAsync(userInfo),
    };
  }
}
